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

## Virtual networks
resource "azurerm_virtual_network" "public" {
  name                = "${azurerm_resource_group.public.name}-vnet"
  location            = azurerm_resource_group.public.location
  resource_group_name = azurerm_resource_group.public.name
  address_space       = ["10.244.0.0/14"]
  tags                = local.default_tags
}

### Private VNet Address Plan:
# - azure-net:vnets.tf/dmz = 10.248.0.0/28 (from 10.248.0.1 to 10.248.0.14), for external access (such as VPN external NIC)
# - azure-net:vpn.tf/data-tier = 10.248.1.0/24 (from 10.248.0.65 to 10.248.1.254), for vpn VM internal NIC
# - azure:privatek8s.tf/privatek8s-tier = 10.249.0.0/16 (from 10.249.0.1 to 10.249.255.254), for the AKS cluster 
resource "azurerm_virtual_network" "private" {
  name                = "${azurerm_resource_group.private.name}-vnet"
  location            = azurerm_resource_group.private.location
  resource_group_name = azurerm_resource_group.private.name
  address_space       = ["10.248.0.0/14"]
  tags                = local.default_tags
}

# Dedicated subnet for external access
resource "azurerm_subnet" "dmz" {
  name                 = "${azurerm_virtual_network.private.name}-dmz"
  resource_group_name  = azurerm_resource_group.private.name
  virtual_network_name = azurerm_virtual_network.private.name
  address_prefixes     = ["10.248.0.0/28"]
}

## Peering
resource "azurerm_virtual_network_peering" "private_public" {
  name                         = "${azurerm_resource_group.public.name}-peering"
  resource_group_name          = azurerm_resource_group.private.name
  virtual_network_name         = azurerm_virtual_network.private.name
  remote_virtual_network_id    = azurerm_virtual_network.public.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
