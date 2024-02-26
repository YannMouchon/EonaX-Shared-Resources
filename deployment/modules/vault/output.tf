output "vault_url" {
  value = "http://${var.participant_name}-vault:${local.vault_port}"
}

output "vault_token" {
  value = local.vault_token
}