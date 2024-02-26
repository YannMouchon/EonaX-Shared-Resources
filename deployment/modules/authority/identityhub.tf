locals {
  identityhub_release_name = "${var.authority.name}-identityhub"

  credential_service_url = "http://${local.identityhub_release_name}:8282/api/resolution"
  did_url                = "did:web:${local.identityhub_release_name}%3A8383:api:did"
}

############################
## VERIFIABLE CREDENTIALS ##
############################

resource "kubernetes_config_map" "verifiable-credentials" {

  metadata {
    name = "${local.identityhub_release_name}-credentials"
  }

  data = {
    "credentials.json" = jsonencode(var.authority.vc)
  }
}

##################
## IDENTITY HUB ##
##################

resource "helm_release" "identity-hub" {
  name              = local.identityhub_release_name
  cleanup_on_fail   = true
  dependency_update = true
  recreate_pods     = true
  repository        = var.helm_chart_repo
  chart             = var.identityhub_chart_name
  version           = var.identityhub_version

  values = [
    yamlencode({

      "imagePullSecrets" : [
        {
          "name" : var.docker_image_pull_secret_name
        }
      ],

      "identityhub" : {
        "image" : {
          "repository" : var.identityhub_repo
          "tag" : var.identityhub_version
        },
        "keys" : {
          "sts" : {
            "publicKeyVaultAlias" : local.publickey_alias
          }
        },
        "did" : {
          "web" : {
            "url" : local.did_url,
            "useHttps" : false
          }
        },
        "postgresql" : {
          "jdbcUrl" : "jdbc:postgresql://${var.postgres_host}/${var.authority.name}",
          "secret" : {
            "name" : var.postgres_credentials_secret_name
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
              "path" : "/${var.authority.name}/ih/(management)(.*)"
            },
            {
              "port" : 8282,
              "path" : "/${var.authority.name}/ih/(resolution)(.*)"
            }
          ]
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