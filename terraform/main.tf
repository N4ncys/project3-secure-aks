
teterraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate4653"
    container_name       = "tfstate"
    key                  = "project3-secure-aks.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

