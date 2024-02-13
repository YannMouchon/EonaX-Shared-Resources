locals {
  server_image = "nginxinc/nginx-unprivileged:1.25.3"
}

resource "kubernetes_deployment" "rs-mock" {
  metadata {
    name = var.name
    labels = {
      app = var.name
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.name
      }
    }
    template {
      metadata {
        labels = {
          app = var.name
        }
      }
      spec {
        container {
          image = local.server_image
          name  = var.name

          env_from {
            config_map_ref {
              name = kubernetes_config_map.rs-mock-config.metadata[0].name
            }
          }
          port {
            container_port = var.server_port
            name           = "rs-mock-port"
          }

          volume_mount {
            mount_path = "/usr/share/nginx/html/registry"
            name       = "participants-config"
          }

          # Uncomment this to assign (more) resources
          #          resources {
          #            limits = {
          #              cpu    = "2"
          #              memory = "512Mi"
          #            }
          #            requests = {
          #              cpu    = "250m"
          #              memory = "50Mi"
          #            }
          #          }
          #          liveness_probe {
          #            http_get {
          #              path = "/"
          #              port = "8080"
          #            }
          #            failure_threshold = 10
          #            period_seconds    = 5
          #            timeout_seconds   = 30
          #          }
        }
        volume {
          name = "participants-config"
          config_map {
            name = kubernetes_config_map.rs-mock-config.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "rs-mock-config" {
  metadata {
    name = "rs-mock-config"
  }

  data = {
    "participants" : jsonencode([
      for p in var.participants_did : {
        did : p,
        status : "ONBOARDED"
      }
    ])
  }
}

resource "kubernetes_service" "rs-mock-service" {
  metadata {
    name = var.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.rs-mock.spec.0.template.0.metadata[0].labels.app
    }
    port {
      name        = "rs-mock-port"
      port        = var.server_port
      target_port = var.server_port
    }
  }
}

resource "kubernetes_ingress_v1" "rs-mock-ingress" {
  metadata {
    name = "rs-mock-ingress"
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
          path = "/${var.name}(/|$)(.*)"
          backend {
            service {
              name = kubernetes_service.rs-mock-service.metadata.0.name
              port {
                number = var.server_port
              }
            }
          }
        }
      }
    }
  }
}
