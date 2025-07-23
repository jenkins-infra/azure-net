# This terraform plan defines the resources necessary to provision the Virtual
# Networks in Azure according to IEP-002:
#   <https://github.com/jenkins-infra/iep/tree/master/iep-002>
#
#                                                  ┌────────────────┐   Vnet peering
#                ┌───────────────────────┐         │                │◄───────────────────┐
#                │                       │         │                │              ┌─────▼──────────────┐
#      ┌─────────►   Public VPN Gateway  ◄─────────│  Public VNet   │              │                    │
#      │         │                       │         │                │              │                    │        ┌───────────────────────────┐
#      │         └───────────────────────┘         │   IPv4 + IPv6  │              │   Public DB        │        │                           │
#      │                                           └────────────────┘            ┌►│                    │        │                           │
#      │                                             │          │                │ │                    │    ┌───►  Public-Sponsored Vnet    │
#                                                    │          │                │ └────────────────────┘    │   │                           │
#  The Internet ─────────────────────────────────────┘    VNet peering           │                           │   │                           │
#                                                               │                │                           │   └───────────────────────────┘
#      │                                                        │                │                           │
#      │                                           ┌────────────▼───┐            │                           │
#      │         ┌───────────────────────┐         │                │◄───────────┘                           │   ┌──────────────────────────┐
#      │         │                       │         │                │ Vnet peering                           │   │                          │
#      ├─────────►  Private VPN Gateway  ◄─────────►  Private VNet  │                    VNet peering        │   │                          │
#      │         │                       │         │                │◄───────────────────────────────────────┘   │   InfraCi-sponsoredvnet  │
#      │         └───────────────────────┘ ┌──────►│                │◄──────────────────────────────────────────►│                          │
#      │                                   │       └───────▲────────┘              Vnet peering                  │                          │
#      │                                   │               │Vnet Peering                                         └──────────────────────────┘
#      │                                   │               │
#      │                            VNet Peering      ┌────▼─────────────┐                        ┌───────────────────────────┐
#      │                                   │          │                  │                        │                           │
#      │                                   │          │                  │                        │                           │
#      │                                   │          │                  │     Vnet peering       │  CertCi-sponsoredVnet     │
#      │                                   │          │   Cert CI VNet   ◄────────────────────────►                           │
#      │                                   │          │                  │                        │                           │
#      │                                   │          │                  │                        └───────────────────────────┘
#      │                                   │          │                  │
#      │                                   │          └──────────────────┘
#      │                                   ▼
#      │                                 ┌──────────────────┐
#      │         ┌───────────────────────┤                  │
#      │         │                       │                  ▼
#      │         │      ┌──────────┐     │                  │
#      └─────────►      │Bounce VM │     │   Trusted VNet   │
#                │      └──────────┘     │                  │
#                │                       │                  │
#                └───────────────────────┤                  │
#                                        └──────────────────┘
# See also https://github.com/jenkins-infra/azure/blob/legacy-tf/plans/vnets.tf

module "public_vnet" {
  source = "./.shared-tools/terraform/modules/azure-full-vnet"

  base_name    = "public"
  gateway_name = "publick8s-outbound"
  # TODO: deprecate this attribute once publick8s AKS cluster is modernized to default to NAT gateway instead of outbound LB
  gateway_subnets_exclude = ["public-vnet-data-tier"]
  tags                    = local.default_tags
  location                = var.location
  vnet_address_space      = ["10.244.0.0/14", "fd00:db8:deca::/48"] # from 10.244.0.1 - to 10.247.255.255
  subnets = [
    {
      # Dedicated subnet for the  "publick8s" AKS cluster resources
      ## Important: the "terraform-production" Enterprise Application used by this repo pipeline needs to be able to manage this virtual network.
      ## See the corresponding role assignment for this vnet added in the (private) terraform-state repo:
      ## https://github.com/jenkins-infra/terraform-states/blob/17df75c38040c9b1087bade3654391bc5db45ffd/azure/main.tf#L59
      name = "publick8s-tier"
      address_prefixes = [
        "10.245.0.0/24",           # 10.245.0.1 - 10.245.0.254
        "fd00:db8:deca:deed::/64", # smaller size as we're using kubenet (required by dual-stack AKS cluster), which allocate one IP per node instead of one IP per pod (in case of Azure CNI)
      ]
      service_endpoints                             = ["Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = false
      private_endpoint_network_policies             = "Enabled"
    },
    {
      # Dedicated subnet for machine to machine private communications
      name                                          = "public-vnet-data-tier"
      address_prefixes                              = ["10.245.1.0/24"] # 10.245.1.1 - 10.245.1.254
      service_endpoints                             = []
      delegations                                   = {}
      private_link_service_network_policies_enabled = false
      private_endpoint_network_policies             = "Enabled"
    },
  ]

  peered_vnets = {
    "${module.private_vnet.vnet_name}"   = module.private_vnet.vnet_id,
    "${module.public_db_vnet.vnet_name}" = module.public_db_vnet.vnet_id,
  }
}

module "private_vnet" {
  source = "./.shared-tools/terraform/modules/azure-full-vnet"

  base_name          = "private"
  tags               = local.default_tags
  location           = var.location
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
    "${module.public_vnet.vnet_name}"                          = module.public_vnet.vnet_id,
    "${module.public_db_vnet.vnet_name}"                       = module.public_db_vnet.vnet_id,
    "${module.cert_ci_jenkins_io_vnet.vnet_name}"              = module.cert_ci_jenkins_io_vnet.vnet_id
    "${module.trusted_ci_jenkins_io_vnet.vnet_name}"           = module.trusted_ci_jenkins_io_vnet.vnet_id
    "${module.infra_ci_jenkins_io_sponsorship_vnet.vnet_name}" = module.infra_ci_jenkins_io_sponsorship_vnet.vnet_id
    "${module.infra_ci_jenkins_io_vnet.vnet_name}"             = module.infra_ci_jenkins_io_vnet.vnet_id
    "${module.private_sponsorship_vnet.vnet_name}"             = module.private_sponsorship_vnet.vnet_id
  }
}

module "private_sponsorship_vnet" {
  source = "./.shared-tools/terraform/modules/azure-full-vnet"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  base_name          = "private-sponsorship"
  gateway_name       = "privatek8s-outbound-sponsorship"
  outbound_ip_count  = 2
  tags               = local.default_tags
  location           = var.location
  vnet_address_space = ["10.240.0.0/14"] # 10.240.0.1 - 10.251.255.254
  subnets = [
    {
      # Dedicated subnet for the "privatek8s-sponsorship" AKS cluster resources on sponsorship account
      ## Important: the "terraform-production" Enterprise Application used by this repo pipeline needs to be able to manage this virtual network.
      ## Ref. https://github.com/jenkins-infra/terraform-states/blob/e5164afee643d7423a6f90f2bc260b89fc36d9e3/azure/main.tf#L114-L129
      name                                          = "privatek8s-sponsorship-tier"
      address_prefixes                              = ["10.241.0.0/16"] # from 10.241.0.0 to 10.241.255.254
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      # Dedicated subnet for the release nodes of the "privatek8s-sponsorship" AKS cluster resources on sponsorship account
      name                                          = "privatek8s-sponsorship-release-tier"
      address_prefixes                              = ["10.242.0.0/25"] # from 10.242.0.0 to 10.242.0.127
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      # Dedicated subnet for the release nodes of the "privatek8s-sponsorship" for the controller infraci AKS cluster resources on sponsorship account
      name                                          = "privatek8s-sponsorship-infraci-ctrl-tier"
      address_prefixes                              = ["10.242.0.128/26"] # from 10.242.0.128 to 10.242.0.191
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      # Dedicated subnet for the private nodes of the "privatek8s-sponsorship" for the controller releaseci AKS cluster resources on sponsorship account
      name                                          = "privatek8s-sponsorship-releaseci-ctrl-tier"
      address_prefixes                              = ["10.242.0.192/26"] # from 10.242.0.192 to 10.242.0.255
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    }
  ]

  peered_vnets = {
    # Accesses through VPN and infra.ci agents
    "${module.private_vnet.vnet_name}" = module.private_vnet.vnet_id,
    # Accesses through the infra.ci agents private vnet
    "${module.infra_ci_jenkins_io_sponsorship_vnet.vnet_name}" = module.infra_ci_jenkins_io_sponsorship_vnet.vnet_id,
    "${module.infra_ci_jenkins_io_vnet.vnet_name}"             = module.infra_ci_jenkins_io_vnet.vnet_id
  }
}

module "trusted_ci_jenkins_io_vnet" {
  source = "./.shared-tools/terraform/modules/azure-full-vnet"

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
  source = "./.shared-tools/terraform/modules/azure-full-vnet"

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
    "${module.private_vnet.vnet_name}"                        = module.private_vnet.vnet_id
    "${module.cert_ci_jenkins_io_sponsorship_vnet.vnet_name}" = module.cert_ci_jenkins_io_sponsorship_vnet.vnet_id
  }
}

module "cert_ci_jenkins_io_sponsorship_vnet" {
  source = "./.shared-tools/terraform/modules/azure-full-vnet"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  base_name          = "cert-ci-jenkins-io-sponsorship"
  gateway_name       = "cert-ci-jenkins-io-outbound-sponsorship"
  outbound_ip_count  = 2
  tags               = local.default_tags
  location           = var.location
  vnet_address_space = ["10.205.0.0/24"] # 10.205.0.1 - 10.205.0.254

  subnets = [
    {
      name                                          = "cert-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"
      address_prefixes                              = ["10.205.0.0/24"] # 10.205.0.1 - 10.205.0.254
      service_endpoints                             = ["Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
  ]

  peered_vnets = {
    "${module.cert_ci_jenkins_io_vnet.vnet_name}" = module.cert_ci_jenkins_io_vnet.vnet_id
  }
}

module "infra_ci_jenkins_io_vnet" {
  source = "./.shared-tools/terraform/modules/azure-full-vnet"

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
    "${module.private_vnet.vnet_name}"                         = module.private_vnet.vnet_id,
    "${module.public_db_vnet.vnet_name}"                       = module.public_db_vnet.vnet_id,
    "${module.private_sponsorship_vnet.vnet_name}"             = module.private_sponsorship_vnet.vnet_id,
    "${module.infra_ci_jenkins_io_sponsorship_vnet.vnet_name}" = module.infra_ci_jenkins_io_sponsorship_vnet.vnet_id
  }
}

module "infra_ci_jenkins_io_sponsorship_vnet" {
  source = "./.shared-tools/terraform/modules/azure-full-vnet"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  base_name          = "infra-ci-jenkins-io-sponsorship"
  gateway_name       = "infra-ci-outbound-sponsorship"
  outbound_ip_count  = 2
  tags               = local.default_tags
  location           = var.location
  vnet_address_space = ["10.206.0.0/22"] # 10.206.0.1 - 10.206.3.254

  subnets = [
    {
      name                                          = "infra-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"
      address_prefixes                              = ["10.206.0.0/24"] # 10.206.0.1 - 10.206.0.254
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
    {
      name                                          = "infra-ci-jenkins-io-sponsorship-vnet-packer-builds"
      address_prefixes                              = ["10.206.1.0/24"] # 10.206.1.1 - 10.206.1.254
      service_endpoints                             = ["Microsoft.KeyVault", "Microsoft.Storage"]
      delegations                                   = {}
      private_link_service_network_policies_enabled = true
      private_endpoint_network_policies             = "Enabled"
    },
  ]

  peered_vnets = {
    "${module.private_vnet.vnet_name}"             = module.private_vnet.vnet_id,
    "${module.public_db_vnet.vnet_name}"           = module.public_db_vnet.vnet_id,
    "${module.private_sponsorship_vnet.vnet_name}" = module.private_sponsorship_vnet.vnet_id,
    "${module.infra_ci_jenkins_io_vnet.vnet_name}" = module.infra_ci_jenkins_io_vnet.vnet_id
  }
}

# separate vNET as Postgres/Mysql flexible server currently doesn't support a vNET with ipv4 and ipv6 address spaces
module "public_db_vnet" {
  source = "./.shared-tools/terraform/modules/azure-full-vnet"

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
    "${module.infra_ci_jenkins_io_sponsorship_vnet.vnet_name}" = module.infra_ci_jenkins_io_sponsorship_vnet.vnet_id
    "${module.infra_ci_jenkins_io_vnet.vnet_name}"             = module.infra_ci_jenkins_io_vnet.vnet_id
    "${module.public_vnet.vnet_name}"                          = module.public_vnet.vnet_id
    "${module.private_vnet.vnet_name}"                         = module.private_vnet.vnet_id
  }
}
