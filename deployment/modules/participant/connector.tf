locals {
  connector_release_name = "${var.participant.name}-connector"

  ##################
  ## IMPORT NOTE! ##
  ############################################################################################
  # These URLs must be the external routes exposed by the participant over the public internet
  # which, are typically exposed through an API gateway, an external Load Balancer...
  # In the case of this MVD we use internal routes for simplicity, but this should not
  # reproduce in prod-grade deployment as all connectors of a dataspace will not be deployed
  # in the same Kubernetes cluster in the real life
  ############################################################################################
  protocol_url = "http://${local.connector_release_name}:8282/api/dsp"
  public_url   = "http://${local.connector_release_name}:8484/api/public"
}

resource "helm_release" "connector" {
  name              = local.connector_release_name
  cleanup_on_fail   = true
  dependency_update = true
  recreate_pods     = true
  repository        = var.helm_chart_repo
  chart             = var.connector_chart_name
  version           = var.connector_version

  values = [
    yamlencode({

      "imagePullSecrets" : [
        {
          "name" : var.docker_image_pull_secret_name
        }
      ],

      "connector" : {
        "image" : {
          "repository" : var.connector_repo
          "tag" : var.connector_version
        },
        "keys" : {
          // use the same key pair for simplicity
          "dataplane" : {
            "privateKeyVaultAlias" : local.privatekey_alias,
            "publicKeyVaultAlias" : local.publickey_alias
          },
          "sts" : {
            "privateKeyVaultAlias" : local.privatekey_alias,
            "publicKeyDid" : local.did_url
          }
        },
        "did" : {
          "web" : {
            "url" : local.did_url
            "useHttps" : false
          }
        },
        "trustedIssuers" : {
          "authority" : {
            "did" : "did:web:authority-identityhub%3A8383:api:did"
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
              "path" : "/${var.participant.name}/cp/(management)(.*)"
            },
            {
              "port" : 8282,
              "path" : "/${var.participant.name}/cp/(dsp)(.*)"
            },
            {
              "port" : 8484,
              "path" : "/${var.participant.name}/dp/(public)(.*)"
            },
            {
              "port" : 8585,
              "path" : "/${var.participant.name}/dp/(data)(.*)"
            }
          ]
        },
        "url" : {
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
            "url" : module.vault.vault_url
            "token" : module.vault.vault_token
          }
        }
      }
    })
  ]

  depends_on = [module.vault]
}