output "postgres_host" {
  value = "${kubernetes_service.pg-service.metadata.0.name}:${var.postgres_port}"
}

output "postgres_username" {
  value = local.pg_username
}

output "postgres_password" {
  value = local.pg_password
}