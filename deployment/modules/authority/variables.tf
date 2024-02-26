variable "authority" {
  type = object({
    name = string,
    vc   = list(any)
  })
}

variable "participants" {
  type = list(object({
    name = string
    did  = string
  }))
}

# POSTGRES
variable "postgres_host" {}
variable "postgres_credentials_secret_name" {}

# FEDERATED CATALOG
variable "federatedcatalog_repo" {}
variable "federatedcatalog_chart_name" {}
variable "federatedcatalog_version" {}

# IDENTITY HUB
variable "identityhub_repo" {}
variable "identityhub_chart_name" {}
variable "identityhub_version" {}

# DOCKER PULL
variable "helm_chart_repo" {}
variable "docker_image_pull_secret_name" {}



