locals {
  catalog_release_name = "${var.authority.name}-federatedcatalog"

  crawler_initial_delay    = 10
  crawler_execution_period = 10
}

resource "helm_release" "federated-catalog" {
  name              = local.catalog_release_name
  cleanup_on_fail   = true
  dependency_update = true
  recreate_pods     = true
  repository        = var.helm_chart_repo
  chart             = var.federatedcatalog_chart_name
  version           = var.federatedcatalog_version

  values = [
    yamlencode({

      "imagePullSecrets" : [
        {
          "name" : var.docker_image_pull_secret_name
        }
      ],

      "federatedcatalog" : {
        "image" : {
          "repository" : var.federatedcatalog_repo
          "tag" : var.federatedcatalog_version
        },
        "did" : {
          "web" : {
            "url" : local.did_url,
            "useHttps" : false
          }
        },
        "crawler" : {
          "participantsRegistry" : {
            "url" : "http://${local.participants_registry_name}:8080/participants.json"
          },
          "cache" : {
            "executionPeriodSeconds" : local.crawler_execution_period
            "executionDelaySeconds" : local.crawler_initial_delay
          }
        },
        "trustedIssuers" : {
          "authority" : {
            "did" : local.did_url
          }
        },
        "keys" : {
          "sts" : {
            "privateKeyVaultAlias" : local.privatekey_alias,
            "publicKeyDid" : local.did_url
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
              "path" : "/${var.authority.name}/catalog/(management)(.*)"
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

  depends_on = [kubernetes_service.registry-service, module.vault]
}