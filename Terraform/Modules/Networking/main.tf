resource "azurerm_virtual_network" "example" {
  name                = var.sub_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  address_space       = [var.address_space]
}

resource "azurerm_subnet" "example" {
  name                 = "Subnet_1"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = [var.address_space]
}

resource "azurerm_network_security_group" "example" {
  name                = "acceptanceTestSecurityGroup1"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}

data "azurerm_network_security_group" "nsg" {
  name                = "Sub_A_NSG"
  resource_group_name = "Subscription_A"
}

variable "nsg" {
  default = {
    name                         = "test1234"
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "80"
    source_address_prefix        = "*"
    destination_address_prefix = "*"
    resource_group_name          = "Subscription_A"
    network_security_group_name  = "Sub_A_NSG"
  }
}


locals {
  priority_list = data.azurerm_network_security_group.nsg.security_rule.*.priority
  #priority = sort([for x in local.priority_list: element(local.priority_list, index(local.priority_list, x)) + 1 if (element(local.priority_list, index(local.priority_list, x) + 1) - element(local.priority_list, index(local.priority_list, x))) == 2 ])[0]
  nsg_rule = flatten([for x in range(100, 1024, 1) : {
    name                        = "${var.nsg.direction}-${var.nsg.protocol}-${var.nsg.destination_port_range}-${var.nsg.access}-${x}"
    priority                    = x
    direction                   = var.nsg.direction
    access                      = var.nsg.access
    protocol                    = var.nsg.protocol
    source_port_range           = var.nsg.source_port_range
    destination_port_range      = var.nsg.destination_port_range
    source_address_prefix       = var.nsg.source_address_prefix
    destination_address_prefix  = var.nsg.destination_address_prefix
    resource_group_name         = var.nsg.resource_group_name
    network_security_group_name = var.nsg.network_security_group_name
    } if !contains(local.priority_list, x)
  ])[0]
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "null_resource" "nsg_rule" {
  provisioner "local-exec" {
    command = "az network nsg rule create -g ${local.nsg_rule.resource_group_name} --nsg-name ${local.nsg_rule.network_security_group_name} -n ${local.nsg_rule.name} --priority ${local.nsg_rule.priority} --source-address-prefix ${local.nsg_rule.source_address_prefix} --source-port-range ${local.nsg_rule.source_port_range} --destination-address-prefix ${local.nsg_rule.destination_address_prefix} --destination-port-range ${local.nsg_rule.destination_port_range} --access ${local.nsg_rule.access} --protocol ${local.nsg_rule.protocol} --direction ${local.nsg_rule.direction}"
  }
}
