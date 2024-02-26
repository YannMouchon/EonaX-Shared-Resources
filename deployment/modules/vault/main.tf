locals {
  vault_token = "root"
  vault_port  = 8200
}

########################################
## HASHICORP VAULT + KEY PAIR SEEDING ##
########################################
resource "helm_release" "vault" {
  repository    = "https://helm.releases.hashicorp.com"
  chart         = "vault"
  name          = "${var.participant_name}-vault"
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

####################
### VAULT INGRESS ##
####################
resource "kubernetes_ingress_v1" "vault-ingress" {
  metadata {
    name = "${var.participant_name}-vault-ingress"
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
          path = "/${var.participant_name}/vault(/|$)(.*)"
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