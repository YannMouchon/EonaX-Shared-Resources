locals {
  privatekey_alias = "connector"
  publickey_alias  = "connector-pub"

  db_name          = "connectordb"
  db_user          = "connector"
  db_user_password = "connectorpwd"
}

module "db" {
  source = "./db-bootstrap"

  db_bootstrap_sql_script_configmap_name = var.db_bootstrap_sql_script_configmap_name
  db_name                                = local.db_name
  db_server_fqdn                         = var.db_server_fqdn
  db_user                                = local.db_user
  db_user_password                       = local.db_user_password
  postgres_admin_credentials_secret_name = var.postgres_admin_credentials_secret_name
}

resource "kubernetes_secret" "db-user-credentials" {

  metadata {
    name = "${local.db_user}-db-credentials"
  }

  data = {
    "username" = local.db_user
    "password" = local.db_user_password
  }
}

