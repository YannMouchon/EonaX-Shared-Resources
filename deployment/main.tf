###################
## POSTGRESQL DB ##
###################

module "postgres" {
  source = "./modules/postgres"
}

#####################
## HASHICORP VAULT ##
#####################
module "vault" {
  source = "./modules/vault"
}


##################
## PARTICIPANTS ##
##################

module "participant" {
  source = "./modules/connector"

  db_server_fqdn                         = module.postgres.postgres_server_fqdn
  db_bootstrap_sql_script_configmap_name = module.postgres.postgres_db_bootstrap_script_configmap_name
  postgres_admin_credentials_secret_name = module.postgres.postgres_admin_credentials_secret_name
  vault_token_secret_name                = module.vault.vault_token_secret_name
  vault_url                              = module.vault.vault_url

  # public facing urls
  control_plane_dsp_url    = var.control_plane_dsp_url
  data_plane_public_url    = var.data_plane_public_url
  identity_hub_did_web_url = var.identity_hub_did_web_url
}
