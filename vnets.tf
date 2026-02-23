# This terraform plan defines the resources necessary to provision the Virtual
# Networks in Azure according to IEP-002:
#   <https://github.com/jenkins-infra/iep/tree/master/iep-002>
#
#                                                  ┌────────────────┐   Vnet peering
#                                                  │                │◄───────────────────┐
#                                                  │                │              ┌─────▼──────────────┐
#                                                  │  Public VNet   │              │                    │
#                                                  │                │              │                    │
#                                                  │   IPv4 + IPv6  │              │   Public DB        │
#                                                  └────────────────┘            ┌►│                    │
#                                                    │          │                │ │                    │
#                                                    │          │                │ └────────────────────┘
#  The Internet ─────────────────────────────────────┘    VNet peering           │
#                                                               │                │
#      │                                                        │                │
#      │                                           ┌────────────▼───┐            │
#      │         ┌───────────────────────┐         │                │◄───────────┘
#      │         │                       │         │                │ Vnet peering
#      ├─────────►  Private VPN Gateway  ◄─────────►  Private VNet  │
#      │         │                       │         │                │
#      │         └───────────────────────┘ ┌──────►│                │
#      │                                   │       └───────▲────────┘
#      │                                   │               │Vnet Peering
#      │                                   │               │
#      │                            VNet Peering      ┌────▼─────────────┐                        ┌────────────────────────┐
#      │                                   │          │                  │                        │                        │
#      │                                   │          │                  │                        │                        │
#      │                                   │          │                  │     Vnet peering       │                        │
#      │                                   │          │   Cert CI VNet   ◄────────────────────────►  CertCi-sponsoredVnet  │
#      │                                   │          │                  │                        │                        │
#      │                                   │          │                  │                        │                        │
#      │                                   │          │                  │                        │                        │
#      │                                   │          └──────────────────┘                        └────────────────────────┘
#      │                                   ▼
#      │                                 ┌──────────────────┐
#      │         ┌───────────────────────┤                  │
#      │         │                       │                  │
#      │         │      ┌──────────┐     │                  │
#      └─────────►      │Bounce VM │     │   Trusted VNet   │
#                │      └──────────┘     │                  │
#                │                       │                  │
#                └───────────────────────┤                  │
#                                        └──────────────────┘
# See also https://github.com/jenkins-infra/azure/blob/legacy-tf/plans/vnets.tf

module "public_vnet" {
  source = "./modules/azure-full-vnet"

  base_name = "public"
  tags      = local.default_tags
  location  = var.location
  # No NAT gateway as the AKS cluster requires an LB for its outbound method (due to IPv6 unsupported on NAT gateways)
  vnet_address_space = ["10.244.0.0/14", "fd00:db8:deca::/48"] # from 10.244.0.1 - to 10.247.255.255
  subnets = [
    {
      # publick8s AKS cluster with Azure CNI and dual-stack
      name = "publick8s"
      address_prefixes = [
        "10.245.2.0/24",           # 10.245.2.1 - 10.245.2.254
        "fd00:db8:deca:deee::/64", # fd00:db8:deca:deee:0:0:0:0 - fd00:db8:deca:deee:ffff:ffff:ffff:ffff
      ]
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = false # Required to define Azure PLS
      private_endpoint_network_policies             = "Enabled"
    },
  ]

  peered_vnets = {
    "${module.private_vnet.vnet_name}"             = module.private_vnet.vnet_id,
    "${module.public_db_vnet.vnet_name}"           = module.public_db_vnet.vnet_id,
    "${module.infra_ci_jenkins_io_vnet.vnet_name}" = module.infra_ci_jenkins_io_vnet.vnet_id,
  }
}

module "private_vnet" {
  source = "./modules/azure-full-vnet"

  base_name         = "private"
  tags              = local.default_tags
  location          = var.location
  gateway_name      = "private-outbound"
  outbound_ip_count = 2
  gateway_subnets_exclude = [
    "private-vnet-dmz", # Outbound method for the VPN VM should use its public IP
  ]
  vnet_address_space = ["10.248.0.0/14"] # 10.248.0.1 - 10.251.255.254
  subnets = [
    {
      # Dedicated subnet for external access (such as VPN external NIC)
      name                                          = "private-vnet-dmz"
      address_prefixes                              = ["10.248.0.0/28"]
      service_endpoints                             = []
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      # Dedicated subnet for machine to machine private communications
      name                                          = "private-vnet-data-tier"
      address_prefixes                              = ["10.248.1.0/24"] # 10.248.1.0 - 10.248.1.255
      service_endpoints                             = []
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      # Dedicated subnet for the "privatek8s" AKS cluster resources
      ## Important: the "terraform-production" Enterprise Application used by this repo pipeline needs to be able to manage this virtual network.
      ## Ref. https://github.com/jenkins-infra/terraform-states/blob/e5164afee643d7423a6f90f2bc260b89fc36d9e3/azure/main.tf#L114-L129
      name                                          = "privatek8s-tier"
      address_prefixes                              = ["10.249.0.0/16"] # from 10.249.0.0 to 10.249.255.254
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      # Dedicated subnet for the release nodes of the "privatek8s" AKS cluster resources
      name                                          = "privatek8s-release-tier"
      address_prefixes                              = ["10.250.0.0/25"] # from 10.250.0.0 to 10.250.0.127
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      # Dedicated subnet for the release nodes of the "privatek8s" for the controller infraci AKS cluster resources
      name                                          = "privatek8s-infraci-ctrl-tier"
      address_prefixes                              = ["10.250.0.128/26"] # from 10.250.0.128 to 10.250.0.191
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      # Dedicated subnet for the private nodes of the "privatek8s" for the controller releaseci AKS cluster resources
      name                                          = "privatek8s-releaseci-ctrl-tier"
      address_prefixes                              = ["10.250.0.192/26"] # from 10.250.0.192 to 10.250.0.255
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    }
  ]

  peered_vnets = {
    "${module.public_vnet.vnet_name}"                = module.public_vnet.vnet_id,
    "${module.public_db_vnet.vnet_name}"             = module.public_db_vnet.vnet_id,
    "${module.cert_ci_jenkins_io_vnet.vnet_name}"    = module.cert_ci_jenkins_io_vnet.vnet_id
    "${module.trusted_ci_jenkins_io_vnet.vnet_name}" = module.trusted_ci_jenkins_io_vnet.vnet_id
    "${module.infra_ci_jenkins_io_vnet.vnet_name}"   = module.infra_ci_jenkins_io_vnet.vnet_id
  }
}

module "trusted_ci_jenkins_io_vnet" {
  source = "./modules/azure-full-vnet"

  base_name          = "trusted-ci-jenkins-io"
  gateway_name       = "trusted-outbound"
  tags               = local.default_tags
  location           = var.location
  vnet_address_space = ["10.252.0.0/21"] # 10.252.0.1 - 10.252.7.254
  subnets = [
    {
      name                                          = "trusted-ci-jenkins-io-vnet-controller"
      address_prefixes                              = ["10.252.0.0/24"] # 10.252.0.1 - 10.252.0.254
      service_endpoints                             = []
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      name                                          = "trusted-ci-jenkins-io-vnet-ephemeral-agents"
      address_prefixes                              = ["10.252.1.0/24"] # 10.252.1.1 - 10.252.1.254
      service_endpoints                             = ["Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      name                                          = "trusted-ci-jenkins-io-vnet-permanent-agents"
      address_prefixes                              = ["10.252.2.0/24"] # 10.252.2.1 - 10.252.2.254
      service_endpoints                             = ["Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Disabled"
    },
  ]

  peered_vnets = {
    "${module.private_vnet.vnet_name}" = module.private_vnet.vnet_id,
  }
}

module "cert_ci_jenkins_io_vnet" {
  source = "./modules/azure-full-vnet"

  base_name          = "cert-ci-jenkins-io"
  gateway_name       = "cert-ci-jenkins-io-outbound"
  tags               = local.default_tags
  location           = var.location
  vnet_address_space = ["10.252.8.0/21"] # 10.252.8.1 - 10.252.15.254

  subnets = [
    {
      name                                          = "cert-ci-jenkins-io-vnet-controller"
      address_prefixes                              = ["10.252.8.0/24"] # 10.252.8.1 - 10.252.8.254
      service_endpoints                             = []
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      name                                          = "cert-ci-jenkins-io-vnet-ephemeral-agents"
      address_prefixes                              = ["10.252.9.0/24"] # 10.252.9.1 - 10.252.9.254
      service_endpoints                             = ["Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
  ]

  peered_vnets = {
    "${module.private_vnet.vnet_name}"                      = module.private_vnet.vnet_id
    "${module.cert_ci_jenkins_io_sponsored_vnet.vnet_name}" = module.cert_ci_jenkins_io_sponsored_vnet.vnet_id
  }
}

module "cert_ci_jenkins_io_sponsored_vnet" {
  source = "./modules/azure-full-vnet"

  providers = {
    azurerm = azurerm.jenkins-sponsored
  }

  base_name          = "cert-ci-jenkins-io-sponsored"
  gateway_name       = "cert-ci-jenkins-io-outbound-sponsored"
  outbound_ip_count  = 2
  tags               = local.default_tags
  location           = var.location
  vnet_address_space = ["10.205.0.0/23"] # 10.205.0.1 - 10.205.1.254

  subnets = [
    {
      name                                          = "cert-ci-jenkins-io-sponsored-vnet-ephemeral-agents"
      address_prefixes                              = ["10.205.0.0/24"] # 10.205.0.1 - 10.205.0.254
      service_endpoints                             = ["Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
  ]

  peered_vnets = {
    "${module.private_vnet.vnet_name}"            = module.private_vnet.vnet_id,
    "${module.cert_ci_jenkins_io_vnet.vnet_name}" = module.cert_ci_jenkins_io_vnet.vnet_id
  }
}

module "infra_ci_jenkins_io_vnet" {
  source = "./modules/azure-full-vnet"

  base_name          = "infra-ci-jenkins-io"
  gateway_name       = "infra-ci-jenkins-io-outbound"
  outbound_ip_count  = 2
  tags               = local.default_tags
  location           = var.location
  vnet_address_space = ["10.5.0.0/22"] # 10.5.0.1 - 10.5.3.254

  subnets = [
    {
      name                                          = "infra-ci-jenkins-io-vnet-ephemeral-agents"
      address_prefixes                              = ["10.5.0.0/24"] # 10.5.0.1 - 10.5.0.254
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      name                                          = "infra-ci-jenkins-io-vnet-packer-builds"
      address_prefixes                              = ["10.5.1.0/24"] # 10.5.1.1 - 10.5.1.254
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      name                                          = "infra-ci-jenkins-io-vnet-kubernetes-agents"
      address_prefixes                              = ["10.5.2.0/24"] # 10.5.2.0 - 10.5.2.254
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
  ]

  peered_vnets = {
    "${module.private_vnet.vnet_name}"   = module.private_vnet.vnet_id,
    "${module.public_db_vnet.vnet_name}" = module.public_db_vnet.vnet_id,
    "${module.public_vnet.vnet_name}"    = module.public_vnet.vnet_id,
  }
}

# separate vNET as Postgres/Mysql flexible server currently doesn't support a vNET with ipv4 and ipv6 address spaces
module "public_db_vnet" {
  source = "./modules/azure-full-vnet"

  base_name          = "public"
  use_existing_rg    = true
  custom_vnet_name   = "public-db-vnet"
  tags               = local.default_tags
  location           = var.location
  vnet_address_space = ["10.253.0.0/21"] # 10.253.0.1 - 10.253.7.254
  subnets = [
    # This subnet is reserved as "delegated" for the pgsql server on the public-db network
    # Ref. https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking
    {
      name                                          = "public-db-vnet-postgres-tier",
      address_prefixes                              = ["10.253.0.0/24"], # 10.253.0.1 - 10.253.0.254,
      service_endpoints                             = [],
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
      delegations = {
        "pgsql" = {
          service_delegations = [{
            name = "Microsoft.DBforPostgreSQL/flexibleServers"
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/join/action",
            ]
          }]
        }
      }
    },
    # This subnet is reserved as "delegated" for the mysql server on the public-db network
    # Ref. https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-networking
    {
      name                                          = "public-db-vnet-mysql-tier",
      address_prefixes                              = ["10.253.1.0/24"] # 10.253.1.1 - 10.253.1.254
      service_endpoints                             = [],
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled",
      delegations = {
        "mysql" = {
          service_delegations = [{
            name = "Microsoft.DBforMySQL/flexibleServers"
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/join/action",
            ]
          }]
        }
      }
    }
  ]
  peered_vnets = {
    "${module.infra_ci_jenkins_io_vnet.vnet_name}" = module.infra_ci_jenkins_io_vnet.vnet_id
    "${module.public_vnet.vnet_name}"              = module.public_vnet.vnet_id
    "${module.private_vnet.vnet_name}"             = module.private_vnet.vnet_id
  }
}
