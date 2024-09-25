locals {
  sql_files_path          = fileset(path.module, "sql/*.sql")
  sql_files_full_path     = formatlist("${path.module}/%s", local.sql_files_path)
  sql_files               = [for p in local.sql_files_full_path : file(p)]
  db_bootstrap_sql_script = join("\n", local.sql_files)
}

#############################
## DB BOOTSTRAP SQL SCRIPT ##
#############################

resource "kubernetes_config_map" "db-bootstrap-sql-script" {

  metadata {
    name = "db-bootstrap-sql-script"
  }

  data = {
    "bootstrap.sql" = local.db_bootstrap_sql_script
  }
}

module "db" {
  source = "./db-bootstrap"

  db_name                                = var.db_name
  db_server_fqdn                         = var.db_server_fqdn
  db_user                                = var.db_username
  db_user_password                       = var.db_password
  postgres_admin_credentials_secret_name = var.postgres_admin_credentials_secret_name
  db_bootstrap_sql_script_configmap_name = kubernetes_config_map.db-bootstrap-sql-script.metadata.0.name
}

resource "kubernetes_secret" "db-user-credentials" {

  metadata {
    name = "${var.db_name}-db-credentials"
  }

  data = {
    "username" = var.db_username
    "password" = var.db_password
  }
}

