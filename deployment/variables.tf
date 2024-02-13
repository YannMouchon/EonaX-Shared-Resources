#############################
## PARTICIPANTS PARAMETERS ##
#############################

variable "participants" {
  type = list(object({
    name                              = string,
    legalName                         = string,
    headquarterCountryCode            = string
    headquarterCountrySubdivisionCode = string
  }))

  default = [
    {
      name : "company1",
      legalName : "Company 1",
      headquarterCountryCode : "FR",
      headquarterCountrySubdivisionCode : "IDF"
    },
    {
      name : "company2",
      legalName : "Company 2",
      headquarterCountryCode : "FR",
      headquarterCountrySubdivisionCode : "IDF"
    }
  ]
}

##########################
## CONNECTOR PARAMETERS ##
##########################

variable "container_registry_username" {
  default     = "amadeusitgroup"
  description = "(Required) Username for authenticating to the Container registry"
}

variable "container_registry_token" {
  sensitive   = true
  description = "(Required) Token for authenticating to the Docker registry"
}

variable "connector_docker_image_repo" {
  default = "ghcr.io/amadeusitgroup/dataspace_ecosystem/eonax-connector-postgresql-hashicorpvault"
}

variable "connector_helm_chart_repo" {
  default = "oci://ghcr.io/amadeusitgroup/dataspace_ecosystem/helm"
}

variable "connector_version" {
  default = "v0.4.1-fix.3"
}
