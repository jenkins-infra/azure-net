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
  address_space       = ["10.244.0.0/14", "fd00:db8:deca::/48"]
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

### dedicated to cert.ci.jenkins.io
data "azurerm_resource_group" "cert_ci_jenkins_io_agents" {
  name = "certci-agents-2"
}
resource "azurerm_virtual_network" "cert_ci_jenkins_io_agents" {
  name                = "jenkinsarm-vnet"
  location            = data.azurerm_resource_group.cert_ci_jenkins_io_agents.location
  resource_group_name = data.azurerm_resource_group.cert_ci_jenkins_io_agents.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.default_tags
}
resource "azurerm_subnet" "cert_ci_jenkins_io_agents" {
  name                 = "jenkinsarm-snet"
  resource_group_name  = data.azurerm_resource_group.cert_ci_jenkins_io_agents.name
  virtual_network_name = azurerm_virtual_network.cert_ci_jenkins_io_agents.name
  address_prefixes     = ["10.0.0.0/24"]
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

# Dedicated subnet for the "privatek8s" AKS cluster resources
## Important: the "terraform-production" Enterprise Application used by this repo pipeline needs to be able to manage this virtual network.
## See the corresponding role assignment for this vnet added in the (private) terraform-state repo:
## https://github.com/jenkins-infra/terraform-states/blob/17df75c38040c9b1087bade3654391bc5db45ffd/azure/main.tf#L59
resource "azurerm_subnet" "privatek8s_tier" {
  name                 = "privatek8s-tier"
  resource_group_name  = azurerm_resource_group.private.name
  virtual_network_name = azurerm_virtual_network.private.name
  address_prefixes     = ["10.249.0.0/16"]
  # Enable KeyVault and Storage service endpoints so the cluster can access secrets to update other clusters, and manage postgresql
  service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

# Dedicated subnet for the release nodes of the "privatek8s" AKS cluster resources
## Important: the "terraform-production" Enterprise Application used by this repo pipeline needs to be able to manage this virtual network.
## See the corresponding role assignment for this vnet added in the (private) terraform-state repo:
## https://github.com/jenkins-infra/terraform-states/blob/17df75c38040c9b1087bade3654391bc5db45ffd/azure/main.tf#L59
resource "azurerm_subnet" "privatek8s_release_tier" {
  name                 = "privatek8s-release-tier"
  resource_group_name  = azurerm_resource_group.private.name
  virtual_network_name = azurerm_virtual_network.private.name
  address_prefixes     = ["10.250.0.0/25"]
  # Enable KeyVault and Storage service endpoints so the cluster can access secrets to update other clusters
  service_endpoints = ["Microsoft.KeyVault"]
}

# Dedicated subnet for the  "publick8s" AKS cluster resources
## Important: the "terraform-production" Enterprise Application used by this repo pipeline needs to be able to manage this virtual network.
## See the corresponding role assignment for this vnet added in the (private) terraform-state repo:
## https://github.com/jenkins-infra/terraform-states/blob/17df75c38040c9b1087bade3654391bc5db45ffd/azure/main.tf#L59
resource "azurerm_subnet" "publick8s_tier" {
  name                 = "publick8s-tier"
  resource_group_name  = azurerm_resource_group.public.name
  virtual_network_name = azurerm_virtual_network.public.name
  address_prefixes     = [
    "10.245.0.0/24", # 10.245.0.1 - 10.245.0.254
    "fd00:db8:deca:deed::/64", # smaller size as we're using kubenet (required by dual-stack AKS cluster), which allocate one IP per node instead of one IP per pod (in case of Azure CNI)
  ]
}

# Dedicated subnet for machine to machine private communications
resource "azurerm_subnet" "public_vnet_data_tier" {
  name                 = "${azurerm_virtual_network.public.name}-data-tier"
  resource_group_name  = azurerm_resource_group.public.name
  virtual_network_name = azurerm_virtual_network.public.name
  address_prefixes     = ["10.245.1.0/24"] # 10.245.1.1 - 10.245.1.254
}

# Dedicated subnets for ci.jenkins.io (controller and agents)
resource "azurerm_subnet" "public_vnet_ci_jenkins_io_agents" {
  name                 = "${azurerm_virtual_network.public.name}-ci_jenkins_io_agents"
  resource_group_name  = azurerm_resource_group.public.name
  virtual_network_name = azurerm_virtual_network.public.name
  address_prefixes     = ["10.245.2.0/23"] # 10.245.2.1 - 10.245.3.254
}
resource "azurerm_subnet" "public_vnet_ci_jenkins_io_controller" {
  name                 = "${azurerm_virtual_network.public.name}-ci_jenkins_io_controller"
  resource_group_name  = azurerm_resource_group.public.name
  virtual_network_name = azurerm_virtual_network.public.name
  address_prefixes     = [
    "10.245.4.0/24", # 10.245.4.1 - 10.245.4.254
    "fdb5:c0c9:9cfc:7658::/64", # smaller size as it only need to support public IPv6 for ci.jenkins.io controller
  ]
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
