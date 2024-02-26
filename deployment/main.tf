locals {
  postgres_credentials_secret_name = "postgres-db"

  docker_image_pull_secret_name = "dockerconfigjson-github-com"
  base64Token                   = base64encode("${var.container_registry_username}:${var.container_registry_token}")
  secretJson                    = "{\"auths\":{\"ghcr.io\":{\"auth\":\"${local.base64Token}\"}}}"

  participants = [var.data_provider, var.data_consumer]
}

###################
## POSTGRESQL DB ##
###################

module "db" {
  source = "./modules/db"

  authority_name    = var.authority.name
  participant_names = [for p in local.participants : p.name]
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

##################
## PARTICIPANTS ##
##################

module "participant" {
  source = "./modules/participant"

  for_each    = { for p in local.participants : p.name => p }
  participant = each.value

  # POSTGRES
  postgres_host                    = module.db.postgres_host
  postgres_credentials_secret_name = kubernetes_secret.postgresql-db-secret.metadata.0.name

  # DOCKER
  docker_image_pull_secret_name = kubernetes_secret_v1.docker-image-pull-secret.metadata.0.name
  helm_chart_repo               = var.helm_chart_repo

  # CONNECTOR
  connector_repo       = var.connector_repo
  connector_chart_name = var.connector_chart_name
  connector_version    = var.connector_version

  # IDENTITY HUB
  identityhub_repo       = var.identityhub_repo
  identityhub_chart_name = var.identityhub_chart_name
  identityhub_version    = var.identityhub_version
}

#########################
## DATASPACE AUTHORITY ##
#########################

module "authority" {
  source = "./modules/authority"

  authority = var.authority

  participants = [
    for p in local.participants : merge(p, {
      did : module.participant[p.name].did_url
    })
  ]

  # POSTGRES
  postgres_host                    = module.db.postgres_host
  postgres_credentials_secret_name = kubernetes_secret.postgresql-db-secret.metadata.0.name

  # DOCKER
  docker_image_pull_secret_name = kubernetes_secret_v1.docker-image-pull-secret.metadata.0.name
  helm_chart_repo               = var.helm_chart_repo

  # FEDERATED CATALOG
  federatedcatalog_chart_name = var.federatedcatalog_chart_name
  federatedcatalog_repo       = var.federatedcatalog_repo
  federatedcatalog_version    = var.federatedcatalog_version

  # IDENTITY HUB
  identityhub_chart_name = var.identityhub_chart_name
  identityhub_version    = var.identityhub_version
  identityhub_repo       = var.identityhub_repo
}