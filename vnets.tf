# This terraform plan defines the resources necessary to provision the Virtual
# Networks in Azure according to IEP-002:
#   <https://github.com/jenkins-infra/iep/tree/master/iep-002>
#
#                                                 ┌──────────────────────────┐
#               ┌───────────────────────┐         │                          │
#               │                       │         │                          │
#     ┌─────────►   Public VPN Gateway  ◄─────────►  Public Production VNet  │
#     │         │                       │         │                          │
#     │         └───────────────────────┘         │                          │
#     │                                           └────────────▲─────────────┘
#     │                                                        │
#                                                              │
# The Internet                                           VNet peering
#                                                              │
#     │                                                        │
#     │                                           ┌────────────▼─────────────┐
#     │         ┌───────────────────────┐         │                          │
#     │         │                       │         │                          │
#     └─────────►  Private VPN Gateway  ◄─────────►  Private Production VNet │
#               │                       │         │                          │
#               └───────────────────────┘         │                          │
#                                                 └──────────────────────────┘
#
#
# See also https://github.com/jenkins-infra/azure/blob/legacy-tf/plans/vnets.tf

## Resource groups
resource "azurerm_resource_group" "prod_public" {
  name     = "prod-jenkins-public"
  location = var.location
  tags     = local.default_tags
}

resource "azurerm_resource_group" "prod_private" {
  name     = "prod-jenkins-private"
  location = var.location
  tags     = local.default_tags
}

## Virtual networks
resource "azurerm_virtual_network" "prod_public" {
  name                = "prod-jenkins-public-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.prod_public.name
  address_space       = ["10.244.0.0/14"]
  tags                = local.default_tags
}

resource "azurerm_virtual_network" "prod_private" {
  name                = "prod-jenkins-private-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.prod_private.name
  address_space       = ["10.248.0.0/14"]
  tags                = local.default_tags
}

## Network Security Groups
resource "azurerm_network_security_group" "prod_public_apptier" {
  name                = "prod-jenkins-public-vnet-apptier"
  location            = var.location
  resource_group_name = azurerm_resource_group.prod_public.name

  # Inbound rules
  security_rule {
    name                   = "allow-http-inbound"
    priority               = 100
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "80"
  }
  security_rule {
    name                   = "allow-https-inbound"
    priority               = 101
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "443"
  }
  security_rule {
    name                   = "allow-ldap-inbound"
    priority               = 102
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "636"
  }
  security_rule {
    name                   = "allow-rsyncd-inbound"
    priority               = 103
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "873"
    source_address_prefix  = "52.167.253.43/32,52.202.51.185/32,52.177.88.13/32"
  }
  security_rule {
    name                   = "allow-public-ssh"
    priority               = 101
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "22"
    source_address_prefix  = "52.167.253.43/32,52.202.51.185/32,52.177.88.13/32"
  }

  tags = local.default_tags
}
