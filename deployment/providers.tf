terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

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

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {

  kubernetes {
    config_path = "~/.kube/config"
  }

  registry {
    url      = var.connector_helm_chart_repo
    username = var.container_registry_username
    password = var.container_registry_token
  }
}