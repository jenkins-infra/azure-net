# This terraform plan defines the resources necessary to provision the Virtual
# Networks in Azure according to IEP-002:
#   <https://github.com/jenkins-infra/iep/tree/master/iep-002>
#
#
#                                                 ┌────────────────┐                              ┌───────────────────────────┐
#               ┌───────────────────────┐         │                │                              │                           │
#               │                       │         │                │                              │                           │
#     ┌─────────►   Public VPN Gateway  ◄─────────►  Public VNet   ◄─────────────────────────────►│  Public-Sponsored Vnet    │
#     │         │                       │         │                │          VNet peering        │                           │
#     │         └───────────────────────┘         │                │                              │                           │
#     │                                           └─▲──────────▲───┘                              └───────────────────────────┘
#     │                                             │          │
#                                                   │          │
# The Internet ─────────────────────────────────────┘    VNet peering
#                                                              │
#     │                                                        │
#     │                                           ┌────────────▼───┐
#     │         ┌───────────────────────┐         │                │
#     │         │                       │         │                │
#     ├─────────►  Private VPN Gateway  ◄─────────►  Private VNet  │
#     │         │                       │         │                │
#     │         └───────────────────────┘         │                │
#     │                                           └────────────▲───┘
#     │                                                        │
#     │                                                        │
#     │                                 ┌──────────────────┐  VNet peering
#     │                                 │                  │   │
#     │                                 │                  │   │
#     │                                 │                  │   │
#     │                                 │   Cert CI VNet   ◄───┘
#     │                                 │                  │
#     │                                 │                  │
#     │                                 │                  │
#     │                                 └──────────────────┘
#     │
#     │                                 ┌──────────────────┐
#     │         ┌───────────────────────┤                  │
#     │         │                       │                  │
#     │         │      ┌──────────┐     │                  │
#     └─────────►      │Bounce VM │     │   Trusted VNet   │
#               │      └──────────┘     │                  │
#               │                       │                  │
#               └───────────────────────┤                  │
#                                       └──────────────────┘
#
#
#
# See also https://github.com/jenkins-infra/azure/blob/legacy-tf/plans/vnets.tf

## Resource groups
resource "azurerm_resource_group" "public" {
  name     = "public"
  location = var.location
  tags     = local.default_tags
}
resource "azurerm_resource_group" "public_jenkins_sponsorship" {
  provider = azurerm.jenkins-sponsorship
  name     = "public-jenkins-sponsorship"
  location = var.location
  tags     = local.default_tags
}
resource "azurerm_resource_group" "private" {
  name     = "private"
  location = var.location
  tags     = local.default_tags
}
resource "azurerm_resource_group" "trusted_ci_jenkins_io" {
  name     = "trusted-ci-jenkins-io"
  location = var.location
  tags     = local.default_tags
}
resource "azurerm_resource_group" "cert_ci_jenkins_io" {
  name     = "cert-ci-jenkins-io"
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
resource "azurerm_virtual_network" "public_jenkins_sponsorship" {
  provider            = azurerm.jenkins-sponsorship
  name                = "${azurerm_resource_group.public_jenkins_sponsorship.name}-vnet"
  location            = azurerm_resource_group.public_jenkins_sponsorship.location
  resource_group_name = azurerm_resource_group.public_jenkins_sponsorship.name
  address_space       = ["10.200.0.0/14"]
  tags                = local.default_tags
}
resource "azurerm_virtual_network" "private" {
  name                = "${azurerm_resource_group.private.name}-vnet"
  location            = azurerm_resource_group.private.location
  resource_group_name = azurerm_resource_group.private.name
  address_space       = ["10.248.0.0/14"]
  tags                = local.default_tags
}
resource "azurerm_virtual_network" "trusted_ci_jenkins_io" {
  name                = "${azurerm_resource_group.trusted_ci_jenkins_io.name}-vnet"
  location            = azurerm_resource_group.trusted_ci_jenkins_io.location
  resource_group_name = azurerm_resource_group.trusted_ci_jenkins_io.name
  address_space       = ["10.252.0.0/21"] # 10.252.0.1 - 10.252.7.254
  tags                = local.default_tags
}
resource "azurerm_virtual_network" "cert_ci_jenkins_io" {
  name                = "${azurerm_resource_group.cert_ci_jenkins_io.name}-vnet"
  location            = azurerm_resource_group.cert_ci_jenkins_io.location
  resource_group_name = azurerm_resource_group.cert_ci_jenkins_io.name
  address_space       = ["10.252.8.0/21"] # 10.252.8.1 - 10.252.15.254
  tags                = local.default_tags
}
# separate vNET as Postgres/Mysql flexible server currently doesn't support a vNET with ipv4 and ipv6 address spaces
resource "azurerm_virtual_network" "public_db" {
  name                = "${azurerm_resource_group.public.name}-db-vnet"
  location            = azurerm_resource_group.public.location
  resource_group_name = azurerm_resource_group.public.name
  address_space       = ["10.253.0.0/21"] # 10.10.253.0.1 - 10.253.7.254
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
  address_prefixes = [
    "10.245.0.0/24",           # 10.245.0.1 - 10.245.0.254
    "fd00:db8:deca:deed::/64", # smaller size as we're using kubenet (required by dual-stack AKS cluster), which allocate one IP per node instead of one IP per pod (in case of Azure CNI)
  ]
  # Enable Storage service endpoint so the cluster can access restricted storage accounts
  service_endpoints = ["Microsoft.Storage"]
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
  address_prefixes = [
    "10.245.4.0/24", # 10.245.4.1 - 10.245.4.254
    "fd00:db8:deca::/64",
  ]
}

# This subnet is reserved as "delegated" for the pgsql server on the public-db network
# Ref. https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking
resource "azurerm_subnet" "public_db_vnet_postgres_tier" {
  name                 = "${azurerm_virtual_network.public_db.name}-postgres-tier"
  resource_group_name  = azurerm_resource_group.public.name
  virtual_network_name = azurerm_virtual_network.public_db.name
  address_prefixes     = ["10.253.0.0/24"] # 10.253.0.1 - 10.253.0.254
  delegation {
    name = "pgsql"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# This subnet is reserved as "delegated" for the mysql server on the public-db network
# Ref. https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-networking
resource "azurerm_subnet" "public_db_vnet_mysql_tier" {
  name                 = "${azurerm_virtual_network.public_db.name}-mysql-tier"
  resource_group_name  = azurerm_resource_group.public.name
  virtual_network_name = azurerm_virtual_network.public_db.name
  address_prefixes     = ["10.253.1.0/24"] # 10.253.1.1 - 10.253.1.254

  delegation {
    name = "mysql"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

## Peerings
# Each peering needs 2 symetric 'azurerm_virtual_network_peering' resources (ref. https://stackoverflow.com/questions/74948296/azure-vnet-peering-initiated-state-when-run-with-terraform)
resource "azurerm_virtual_network_peering" "private_to_public" {
  name                         = "${azurerm_virtual_network.private.name}-to-${azurerm_virtual_network.public.name}"
  resource_group_name          = azurerm_virtual_network.private.resource_group_name
  virtual_network_name         = azurerm_virtual_network.private.name
  remote_virtual_network_id    = azurerm_virtual_network.public.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
resource "azurerm_virtual_network_peering" "public_to_private" {
  name                         = "${azurerm_virtual_network.public.name}-to-${azurerm_virtual_network.private.name}"
  resource_group_name          = azurerm_virtual_network.public.resource_group_name
  virtual_network_name         = azurerm_virtual_network.public.name
  remote_virtual_network_id    = azurerm_virtual_network.private.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
resource "azurerm_virtual_network_peering" "public_to_public_db" {
  name                         = "${azurerm_virtual_network.public.name}-to-${azurerm_virtual_network.public_db.name}"
  resource_group_name          = azurerm_virtual_network.public.resource_group_name
  virtual_network_name         = azurerm_virtual_network.public.name
  remote_virtual_network_id    = azurerm_virtual_network.public_db.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
resource "azurerm_virtual_network_peering" "public_db_to_public" {
  name                         = "${azurerm_virtual_network.public_db.name}-to-${azurerm_virtual_network.public.name}"
  resource_group_name          = azurerm_virtual_network.public_db.resource_group_name
  virtual_network_name         = azurerm_virtual_network.public_db.name
  remote_virtual_network_id    = azurerm_virtual_network.public.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
resource "azurerm_virtual_network_peering" "private_to_public_db" {
  name                         = "${azurerm_virtual_network.private.name}-to-${azurerm_virtual_network.public_db.name}"
  resource_group_name          = azurerm_virtual_network.private.resource_group_name
  virtual_network_name         = azurerm_virtual_network.private.name
  remote_virtual_network_id    = azurerm_virtual_network.public_db.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
resource "azurerm_virtual_network_peering" "public_db_to_private" {
  name                         = "${azurerm_virtual_network.public_db.name}-to-${azurerm_virtual_network.private.name}"
  resource_group_name          = azurerm_virtual_network.public_db.resource_group_name
  virtual_network_name         = azurerm_virtual_network.public_db.name
  remote_virtual_network_id    = azurerm_virtual_network.private.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
resource "azurerm_virtual_network_peering" "private_to_cert" {
  name                         = "${azurerm_virtual_network.private.name}-to-${azurerm_virtual_network.cert_ci_jenkins_io.name}"
  resource_group_name          = azurerm_virtual_network.private.resource_group_name
  virtual_network_name         = azurerm_virtual_network.private.name
  remote_virtual_network_id    = azurerm_virtual_network.cert_ci_jenkins_io.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
resource "azurerm_virtual_network_peering" "cert_to_private" {
  name                         = "${azurerm_virtual_network.cert_ci_jenkins_io.name}-to-${azurerm_virtual_network.private.name}"
  resource_group_name          = azurerm_virtual_network.cert_ci_jenkins_io.resource_group_name
  virtual_network_name         = azurerm_virtual_network.cert_ci_jenkins_io.name
  remote_virtual_network_id    = azurerm_virtual_network.private.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
resource "azurerm_virtual_network_peering" "private_to_trusted" {
  name                         = "${azurerm_virtual_network.private.name}-to-${azurerm_virtual_network.trusted_ci_jenkins_io.name}"
  resource_group_name          = azurerm_virtual_network.private.resource_group_name
  virtual_network_name         = azurerm_virtual_network.private.name
  remote_virtual_network_id    = azurerm_virtual_network.trusted_ci_jenkins_io.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
resource "azurerm_virtual_network_peering" "trusted_to_private" {
  name                         = "${azurerm_virtual_network.trusted_ci_jenkins_io.name}-to-${azurerm_virtual_network.private.name}"
  resource_group_name          = azurerm_virtual_network.trusted_ci_jenkins_io.resource_group_name
  virtual_network_name         = azurerm_virtual_network.trusted_ci_jenkins_io.name
  remote_virtual_network_id    = azurerm_virtual_network.private.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_subnet" "trusted_ci_jenkins_io_controller" {
  name                 = "${azurerm_virtual_network.trusted_ci_jenkins_io.name}-controller"
  resource_group_name  = azurerm_resource_group.trusted_ci_jenkins_io.name
  virtual_network_name = azurerm_virtual_network.trusted_ci_jenkins_io.name
  address_prefixes     = ["10.252.0.0/24"] # 10.252.0.1 - 10.252.0.254
}
resource "azurerm_subnet" "trusted_ci_jenkins_io_ephemeral_agents" {
  name                 = "${azurerm_virtual_network.trusted_ci_jenkins_io.name}-ephemeral-agents"
  resource_group_name  = azurerm_resource_group.trusted_ci_jenkins_io.name
  virtual_network_name = azurerm_virtual_network.trusted_ci_jenkins_io.name
  address_prefixes     = ["10.252.1.0/24"] # 10.252.1.1 - 10.252.1.254
}
resource "azurerm_subnet" "trusted_ci_jenkins_io_permanent_agents" {
  name                 = "${azurerm_virtual_network.trusted_ci_jenkins_io.name}-permanent-agents"
  resource_group_name  = azurerm_resource_group.trusted_ci_jenkins_io.name
  virtual_network_name = azurerm_virtual_network.trusted_ci_jenkins_io.name
  address_prefixes     = ["10.252.2.0/24"] # 10.252.2.1 - 10.252.2.254
}

# Dedicated subnets for cert.ci.jenkins.io (controller and agents)
resource "azurerm_subnet" "cert_ci_jenkins_io_controller" {
  name                 = "${azurerm_virtual_network.cert_ci_jenkins_io.name}-controller"
  resource_group_name  = azurerm_resource_group.cert_ci_jenkins_io.name
  virtual_network_name = azurerm_virtual_network.cert_ci_jenkins_io.name
  address_prefixes     = ["10.252.8.0/24"] # 10.252.8.1 - 10.252.8.254
}
resource "azurerm_subnet" "cert_ci_jenkins_io_ephemeral_agents" {
  name                 = "${azurerm_virtual_network.cert_ci_jenkins_io.name}-ephemeral-agents"
  resource_group_name  = azurerm_resource_group.cert_ci_jenkins_io.name
  virtual_network_name = azurerm_virtual_network.cert_ci_jenkins_io.name
  address_prefixes     = ["10.252.9.0/24"] # 10.252.9.1 - 10.252.9.254
}
