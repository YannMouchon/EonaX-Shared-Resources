output "postgres_server_fqdn" {
  value = kubernetes_service.db-service.metadata[0].name
}

output "postgres_admin_credentials_secret_name" {
  value = kubernetes_secret.db-admin-credentials.metadata.0.name
}

output "postgres_db_bootstrap_script_configmap_name" {
  value = kubernetes_config_map.db-bootstrap-sql-script.metadata.0.name
}