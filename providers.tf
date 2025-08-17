# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.33.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      #version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
  }
  required_version = ">= 1.12.0"

# Backend
backend "remote" {
  organization = "Glitcher255_tf"

  workspaces { 
    name = "Terraform_Kubernetes_Boutique"
  }
#}
}
}

# Microsoft Azure provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}