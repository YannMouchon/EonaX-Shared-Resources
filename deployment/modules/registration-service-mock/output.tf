output "registration_service_host" {
  value = "${kubernetes_service.rs-mock-service.metadata.0.name}:${var.server_port}"
}