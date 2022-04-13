locals {
  sub_name      = "Subscription_B"
  address_space = "10.0.2.0/24"
}

provider "azurerm" {
  features {}
  subscription_id = "f06a0be6-fe70-4fca-a3aa-9c0bc23f66cf"
}

resource "azurerm_resource_group" "example" {
  name     = local.sub_name
  location = "West Europe"
}

module "Networking" {
  source         = "../../Modules/Networking"
  sub_name       = local.sub_name
  resource_group = azurerm_resource_group.example
  address_space  = local.address_space
}
