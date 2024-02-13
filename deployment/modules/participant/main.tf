locals {
  release_name = var.participant.name

  privatekey_alias = var.participant.name
  publickey_alias  = "${local.privatekey_alias}-pub"

  default_token_validity   = 3600
  crawler_inital_delay     = 30
  crawler_execution_period = 30

  ##################
  ## IMPORT NOTE! ##
  ############################################################################################
  # These URLs must be the external routes exposed by the participant over the public internet
  # which, are typically exposed through an API gateway, an external Load Balancer...
  # In the case of this MVD we use internal routes for simplicity, but this should not
  # reproduce in prod-grade deployment as all connectors of a dataspace will not be deployed
  # in the same Kubernetes cluster in the real life
  ############################################################################################
  protocol_url = "http://${local.release_name}-connector:8282/api/dsp"
  public_url   = "http://${local.release_name}-connector:8484/api/public"
  identity_url = "http://${local.release_name}-connector:8686/api/identity"
  did_url      = "did:web:${local.release_name}-didserver%3A8080:webdid" # see https://w3c-ccg.github.io/did-method-web/

  newman_image = "postman/newman:ubuntu"
  vault_token  = "root"
  vault_port   = 8200
}

#######################
## GENERATE KEY PAIR ##
#######################
resource "tls_private_key" "private-key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

data "tls_public_key" "public-key" {
  private_key_pem = tls_private_key.private-key.private_key_pem
}

data "jwks_from_key" "public-key-jwk" {
  key = data.tls_public_key.public-key.public_key_pem
  kid = var.participant.name
}

########################################
## HASHICORP VAULT + KEY PAIR SEEDING ##
########################################
resource "helm_release" "vault" {
  repository    = "https://helm.releases.hashicorp.com"
  chart         = "vault"
  name          = "${var.participant.name}-vault"
  wait_for_jobs = true

  values = [
    yamlencode({
      "injector" : {
        "enabled" : false
      }
      "server" : {
        "dev" : {
          "enabled" : true,
          "devRootToken" : local.vault_token
        },
        "readinessProbe" : {
          "path" : "/v1/sys/health"
        }
      }
    })
  ]
}

resource "kubernetes_config_map" "vault-seeding-config" {

  depends_on = [helm_release.vault]

  metadata {
    name = "${var.participant.name}-vault-seeder-config"
  }

  data = {
    "secrets_seeding.postman_collection.json" = file("${path.module}/vault_seeding.json")
  }
}

resource "kubernetes_job" "vault-seeding-job" {

  depends_on = [helm_release.vault]

  metadata {
    name = "${var.participant.name}-vault-seeding-job"
  }

  spec {
    template {
      metadata {}
      spec {
        container {
          name  = "${var.participant.name}-newman"
          image = local.newman_image

          args = [
            "run",
            "secrets_seeding.postman_collection.json",
            "--env-var",
            "vaultUrl=http://${var.participant.name}-vault:8200/v1/secret/data",
            "--env-var",
            "vaultToken=root",
            "--env-var",
            "publicKeyAlias=${local.publickey_alias}",
            "--env-var",
            "publicKey=${replace(data.tls_public_key.public-key.public_key_pem, "\n", "\\n")}",
            "--env-var",
            "privateKeyAlias=${local.privatekey_alias}",
            "--env-var",
            "privateKey=${replace(tls_private_key.private-key.private_key_pem, "\n", "\\n")}"
          ]

          working_dir = "/vault"

          volume_mount {
            mount_path = "/vault"
            name       = "postman"
          }
        }

        volume {
          name = "postman"
          config_map {
            name = kubernetes_config_map.vault-seeding-config.metadata.0.name
          }
        }
      }
    }
  }
}

###################
## VAULT INGRESS ##
###################
resource "kubernetes_ingress_v1" "vault-ingress" {
  metadata {
    name = "${var.participant.name}-vault-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/${var.participant.name}/vault(/|$)(.*)"
          backend {
            service {
              name = helm_release.vault.metadata.0.name
              port {
                number = local.vault_port
              }
            }
          }
        }
      }
    }
  }
}

###########################
## PARTICIPANT CONNECTOR ##
###########################

resource "helm_release" "connector" {
  name              = local.release_name
  cleanup_on_fail   = true
  dependency_update = true
  recreate_pods     = true
  repository        = var.connector_helm_chart_repo
  chart             = "connector"
  version           = var.connector_version

  values = [
    yamlencode({
      "fullnameOverride" : var.participant.name,

      "imagePullSecrets" : [
        {
          "name" : var.docker_image_pull_secret_name
        }
      ],

      "participant" : {
        "name" : var.participant.name
        "legalName" : var.participant.legalName
        "countryCode" : var.participant.headquarterCountryCode
        "countrySubdivisionCode" : var.participant.headquarterCountrySubdivisionCode
      },

      "connector" : {
        "image" : {
          "repository" : var.connector_docker_image_repo
          "tag" : var.connector_version
        },
        "security" : {
          "privatekey" : local.privatekey_alias
          "publickey" : local.publickey_alias
        },
        "transfer" : {
          "token" : {
            "validity" : local.default_token_validity
          }
        },
        "ingress" : {
          "enabled" : true
          "className" : "nginx"
          "annotations" : {
            "nginx.ingress.kubernetes.io/ssl-redirect" : "false"
            "nginx.ingress.kubernetes.io/use-regex" : "true"
            "nginx.ingress.kubernetes.io/rewrite-target" : "/api/$1$2"
          },
          "endpoints" : [
            {
              "port" : 8181,
              "path" : "/${var.participant.name}/(management)(.*)"
            },
            {
              "port" : 8282,
              "path" : "/${var.participant.name}/(dsp)(.*)"
            },
            {
              "port" : 8484,
              "path" : "/${var.participant.name}/(public)(.*)"
            },
            {
              "port" : 8585,
              "path" : "/${var.participant.name}/(data)(.*)"
            },
            {
              "port" : 8686,
              "path" : "/${var.participant.name}/(identity)(.*)"
            }
          ]
        },
        "crawler" : {
          "registrationServiceUrl" : var.registration_service_url,
          "cache" : {
            "executionPeriodSeconds" : local.crawler_execution_period
            "executionDelaySeconds" : local.crawler_inital_delay
          }
        },
        "url" : {
          "protocol" : local.protocol_url
          "identity" : local.identity_url
          "public" : local.public_url
        },
        "postgresql" : {
          "jdbcUrl" : "jdbc:postgresql://${var.postgres_host}/${var.participant.name}",
          "secret" : {
            "name" : var.postgres_credentials_secret_name
          }
        },
        "vault" : {
          "hashicorp" : {
            "url" : "http://${var.participant.name}-vault:${local.vault_port}"
            "token" : local.vault_token
          }
        }
      },

      "didserver" : {
        "ingress" : {
          "enabled" : true,
          "className" : "nginx",
          "annotations" : {
            "nginx.ingress.kubernetes.io/ssl-redirect" : "false"
            "nginx.ingress.kubernetes.io/use-regex" : "true"
            "nginx.ingress.kubernetes.io/rewrite-target" : "/$2"
          },
          "endpoints" : [
            {
              "port" : 8080,
              "path" : "/${var.participant.name}/didserver(/|$)(.*)"
            }
          ]
        }
      },

      "ssi" : {
        "did" : {
          "web" : {
            "url" : local.did_url,
            "useHttps" : false
          },
          "document" : {
            "publickey" : {
              "jwk" : data.jwks_from_key.public-key-jwk.jwks
            }
          }
        }
      }
    })
  ]

  depends_on = [kubernetes_job.vault-seeding-job]
}