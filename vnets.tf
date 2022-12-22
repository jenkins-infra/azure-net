# This terraform plan defines the resources necessary to provision the Virtual
# Networks in Azure according to IEP-002:
#   <https://github.com/jenkins-infra/iep/tree/master/iep-002>
#
#                                                 ┌────────────────┐
#               ┌───────────────────────┐         │                │
#               │                       │         │                │
#     ┌─────────►   Public VPN Gateway  ◄─────────►  Public VNet   │
#     │         │                       │         │                │
#     │         └───────────────────────┘         │                │
#     │                                           └─▲──────────▲───┘
#     │                                             │          │
#                                                   │          │
# The Internet ─────────────────────────────────────┘    VNet peering
#                                                              │
#     │                                                        │
#     │                                           ┌────────────▼───┐
#     │         ┌───────────────────────┐         │                │
#     │         │                       │         │                │
#     └─────────►  Private VPN Gateway  ◄─────────►  Private VNet  │
#               │                       │         │                │
#               └───────────────────────┘         │                │
#                                                 └────────────────┘
#
# See also https://github.com/jenkins-infra/azure/blob/legacy-tf/plans/vnets.tf

## Resource groups
resource "azurerm_resource_group" "public" {
  name     = "public"
  location = var.location
  tags     = local.default_tags
}

resource "azurerm_resource_group" "private" {
  name     = "private"
  location = var.location
  tags     = local.default_tags
}

resource "azurerm_resource_group" "vpn" {
  name     = "vpn"
  location = var.location
  tags     = local.default_tags
}

## Virtual networks
resource "azurerm_virtual_network" "public" {
  name                = "${azurerm_resource_group.public.name}-vnet"
  location            = azurerm_resource_group.public.location
  resource_group_name = azurerm_resource_group.public.name
  address_space       = ["10.244.0.0/14"]
  tags                = local.default_tags
}

### Private VNet Address Plan:
# - azure/privatek8s: 10.249.0.0/16 (x16 from 10.249.0.1 to 10.249.255.254)
resource "azurerm_virtual_network" "private" {
  name                = "${azurerm_resource_group.private.name}-vnet"
  location            = azurerm_resource_group.private.location
  resource_group_name = azurerm_resource_group.private.name
  address_space       = ["10.248.0.0/14"]
  tags                = local.default_tags
}

### VPN VNet Address Plan:
# - azure-net/vpn: 10.9.0.0/28 (x16 from 10.9.0.1 to 10.9.0.14)
resource "azurerm_virtual_network" "vpn" {
  name                = "${azurerm_resource_group.vpn.name}-vnet"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name
  address_space       = ["10.9.0.0/24"]
  tags                = local.default_tags
}

## Peering
resource "azurerm_virtual_network_peering" "private_public" {
  name                         = "${azurerm_resource_group.private.name}-${azurerm_resource_group.public.name}-peering"
  resource_group_name          = azurerm_resource_group.private.name
  virtual_network_name         = azurerm_virtual_network.private.name
  remote_virtual_network_id    = azurerm_virtual_network.public.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "vpn_private" {
  name                         = "${azurerm_resource_group.vpn.name}-${azurerm_resource_group.private.name}-peering"
  resource_group_name          = azurerm_resource_group.vpn.name
  virtual_network_name         = azurerm_virtual_network.vpn.name
  remote_virtual_network_id    = azurerm_virtual_network.private.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

## Network Security Groups
resource "azurerm_network_security_group" "public_apptier" {
  name                = "${azurerm_resource_group.public.name}-nsg-apptier"
  location            = azurerm_resource_group.public.location
  resource_group_name = azurerm_resource_group.public.name

  ## Inbound rules

  #tfsec:ignore:azure-network-no-public-ingress
  security_rule {
    name                       = "allow-http-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  #tfsec:ignore:azure-network-no-public-ingress
  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  #tfsec:ignore:azure-network-no-public-ingress
  security_rule {
    name                       = "allow-ldap-inbound"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "636"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                   = "allow-rsyncd-inbound"
    priority               = 103
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "873"
    # 52.202.51.185: pkg.origin.jenkins.io
    # TODO: replace by the object reference data when all DNS entries will be imported
    source_address_prefixes    = ["52.202.51.185/32"]
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-private-ssh-inbound"
    priority                   = 4001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = azurerm_virtual_network.private.address_space
    destination_address_prefix = "*"
  }

  ## Outbound rules
  security_rule {
    name                         = "allow-puppet-outbound"
    priority                     = 2100
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "8140"
    source_address_prefix        = "*"
    destination_address_prefixes = azurerm_virtual_network.private.address_space
  }
  #tfsec:ignore:azure-network-no-public-egress
  security_rule {
    name                       = "allow-https-outbound"
    priority                   = 2101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.default_tags
}
