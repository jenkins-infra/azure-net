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

### Private VNet
resource "azurerm_virtual_network" "private" {
  name                = "${azurerm_resource_group.private.name}-vnet"
  location            = azurerm_resource_group.private.location
  resource_group_name = azurerm_resource_group.private.name
  address_space       = ["10.248.0.0/14"]
  tags                = local.default_tags
}

# Dedicated subnet for external access (such as VPN external NIC)
resource "azurerm_subnet" "dmz" {
  name                 = "${azurerm_virtual_network.private.name}-dmz"
  resource_group_name  = azurerm_resource_group.private.name
  virtual_network_name = azurerm_virtual_network.private.name
  address_prefixes     = ["10.248.0.0/28"]
}

# Dedicated subnet for machine to machine private communications
resource "azurerm_subnet" "private_vnet_data_tier" {
  name                 = "${azurerm_virtual_network.private.name}-data-tier"
  resource_group_name  = azurerm_resource_group.private.name
  virtual_network_name = azurerm_virtual_network.private.name
  address_prefixes     = ["10.248.1.0/24"]
}

# Dedicated subnet for the  "privatek8s" AKS cluster resources
## Important: the "terraform-production" Enterprise Application used by this repo pipeline needs to be able to manage this subnet.
## See the corresponding role assignment for this cluster added in the (private) terraform-state repo:
## https://github.com/jenkins-infra/terraform-states/blob/1f44cdb8c6837021b1007fef383207703b0f4d76/azure/main.tf#L49
resource "azurerm_subnet" "privatek8s_tier" {
  name                 = "privatek8s-tier"
  resource_group_name  = azurerm_resource_group.private.name
  virtual_network_name = azurerm_virtual_network.private.name
  address_prefixes     = ["10.249.0.0/16"]
  # Enable KeyVault service endpoint so the cluster can access secrets to update other clusters
  service_endpoints = ["Microsoft.KeyVault"]
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
