terraform {
  required_version = ">=1.12"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">=4.0"

    }
  }
}
provider "azurerm" {
    features{}
    subscription_id = "3336cfab-43be-4332-8565-f3e2f10c270d"
}