locals {
  postgres_credentials_secret_name = "postgres-db"

  docker_image_pull_secret_name = "dockerconfigjson-github-com"
  base64Token                   = base64encode("${var.container_registry_username}:${var.container_registry_token}")
  secretJson                    = "{\"auths\":{\"ghcr.io\":{\"auth\":\"${local.base64Token}\"}}}"

  registration_service_mock_name = "registration-service-mock"
  registration_service_mock_port = 8080
  registration_service_mock_host = "${local.registration_service_mock_name}:${local.registration_service_mock_port}"
}

###################
## POSTGRESQL DB ##
###################

module "db" {
  source = "./modules/db"

  participant_names = [for p in var.participants : p.name]
}

####################################
## K8S SECRET WITH DB CREDENTIALS ##
####################################

resource "kubernetes_secret" "postgresql-db-secret" {

  metadata {
    name = local.postgres_credentials_secret_name
  }

  data = {
    "username" = module.db.postgres_username
    "password" = module.db.postgres_password
  }
}

##############################
## DOCKER IMAGE PULL SECRET ##
##############################

resource "kubernetes_secret_v1" "docker-image-pull-secret" {

  metadata {
    name = local.docker_image_pull_secret_name
  }

  data = {
    ".dockerconfigjson" = local.secretJson
  }

  type = "kubernetes.io/dockerconfigjson"
}

#########################
## EONA-X PARTICIPANTS ##
#########################

module "participant" {
  source = "./modules/participant"

  for_each                         = { for p in var.participants : p.name => p }
  participant                      = each.value
  postgres_host                    = module.db.postgres_host
  registration_service_url         = "http://${local.registration_service_mock_host}"
  postgres_credentials_secret_name = kubernetes_secret.postgresql-db-secret.metadata.0.name
  docker_image_pull_secret_name    = local.docker_image_pull_secret_name
  connector_docker_image_repo      = var.connector_docker_image_repo
  connector_helm_chart_repo        = var.connector_helm_chart_repo
  connector_version                = var.connector_version
}

###############################
## REGISTRATION SERVICE MOCK ##
###############################

module "registration-service-mock" {
  source = "./modules/registration-service-mock"

  participants_did = [for p in module.participant : p.did_url]
  name             = local.registration_service_mock_name
  server_port      = local.registration_service_mock_port
}