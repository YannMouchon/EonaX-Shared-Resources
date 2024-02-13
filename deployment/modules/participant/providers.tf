terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }

    tls = {
      source = "hashicorp/tls"
    }

    jwks = {
      source = "iwarapter/jwks"
    }
  }
}