locals {
  server_image     = "nginxinc/nginx-unprivileged:1.25.3"
  backend-api-name = "${var.participant.name}-api"
  server_port      = 8080
}

resource "kubernetes_deployment" "backend-api" {
  metadata {
    name = local.backend-api-name
    labels = {
      app = local.backend-api-name
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.backend-api-name
      }
    }
    template {
      metadata {
        labels = {
          app = local.backend-api-name
        }
      }
      spec {
        container {
          image = local.server_image
          name  = local.backend-api-name

          env_from {
            config_map_ref {
              name = kubernetes_config_map.backend-api-config.metadata[0].name
            }
          }
          port {
            container_port = local.server_port
            name           = "api-port"
          }

          volume_mount {
            mount_path = "/usr/share/nginx/html"
            name       = "api-config"
          }
        }
        volume {
          name = "api-config"
          config_map {
            name = kubernetes_config_map.backend-api-config.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "backend-api-config" {
  metadata {
    name = local.backend-api-name
  }

  data = {
    "data.json" : jsonencode({ message = "Hello World!" })
  }
}

resource "kubernetes_service" "backend-api-service" {
  metadata {
    name = local.backend-api-name
  }
  spec {
    selector = {
      app = kubernetes_deployment.backend-api.spec.0.template.0.metadata[0].labels.app
    }
    port {
      name        = "api-port"
      port        = local.server_port
      target_port = local.server_port
    }
  }
}

resource "kubernetes_ingress_v1" "backend-api-ingress" {
  metadata {
    name = local.backend-api-name
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
          path = "/${var.participant.name}/${local.backend-api-name}(/|$)(.*)"
          backend {
            service {
              name = kubernetes_service.backend-api-service.metadata.0.name
              port {
                number = local.server_port
              }
            }
          }
        }
      }
    }
  }
}
