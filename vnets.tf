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
  name                = "${azurerm_resource_group.prod_public.name}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.prod_public.name
  address_space       = ["10.244.0.0/14"]
  tags                = local.default_tags
}

resource "azurerm_virtual_network" "prod_private" {
  name                = "${azurerm_resource_group.prod_private.name}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.prod_private.name
  address_space       = ["10.248.0.0/14"]
  tags                = local.default_tags
}

## Peering
resource "azurerm_virtual_network_peering" "prod_private_public" {
  name                         = "${azurerm_resource_group.prod_public.name}-peering"
  resource_group_name          = azurerm_resource_group.prod_private.name
  virtual_network_name         = azurerm_virtual_network.prod_private.name
  remote_virtual_network_id    = azurerm_virtual_network.prod_public.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit = false
  use_remote_gateways = false
}
