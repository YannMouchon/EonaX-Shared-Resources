variable "participant" {
  type = object({
    name                              = string,
    legalName                         = string,
    headquarterCountryCode            = string
    headquarterCountrySubdivisionCode = string
  })
}

variable "connector_docker_image_repo" {}

variable "connector_helm_chart_repo" {}

variable "connector_version" {}

variable "registration_service_url" {}

variable "postgres_host" {}

variable "postgres_credentials_secret_name" {}

variable "docker_image_pull_secret_name" {}