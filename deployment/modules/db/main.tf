locals {
  pg_image    = "postgres:15.3-alpine3.18"
  pg_username = "postgres"
  pg_password = "postgres"

  sql_files_path      = fileset(path.module, "sql/*.sql")
  sql_files_full_path = formatlist("${path.module}/%s", local.sql_files_path)
  sql_files           = [for p in local.sql_files_full_path : file(p)]
  db_bootstrap_script = join("\n", local.sql_files)
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name = "postgres"
    labels = {
      app = "postgres"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }
      spec {
        container {
          image = local.pg_image
          name  = "postgres"

          env {
            name  = "POSTGRES_USER"
            value = local.pg_username
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = local.pg_password
          }

          port {
            container_port = var.postgres_port
            name           = "postgres-port"
          }

          volume_mount {
            mount_path = "/docker-entrypoint-initdb.d/"
            name       = "pg-initdb"
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
          liveness_probe {
            exec {
              command = ["pg_isready", "-U", "postgres"]
            }
            failure_threshold = 10
            period_seconds    = 5
            timeout_seconds   = 30
          }
        }
        volume {
          name = "pg-initdb"
          config_map {
            name = kubernetes_config_map.postgres-config.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "postgres-config" {
  metadata {
    name = "pg-initdb-config"
  }

  data = {
    "db_bootstrap_script.sql" = local.db_bootstrap_script
    "init.sh" = templatefile("${path.module}/init.sh", {
      participants : join(" ", concat([var.authority_name], var.participant_names))
    })
  }
}

resource "kubernetes_service" "pg-service" {
  metadata {
    name = "postgres"
  }
  spec {
    selector = {
      app = kubernetes_deployment.postgres.spec.0.template.0.metadata[0].labels.app
    }
    port {
      name        = "pg-port"
      port        = var.postgres_port
      target_port = var.postgres_port
    }
  }
}
