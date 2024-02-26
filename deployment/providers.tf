terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    helm = {
      source = "hashicorp/helm"
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
    url      = var.helm_chart_repo
    username = var.container_registry_username
    password = var.container_registry_token
  }
}