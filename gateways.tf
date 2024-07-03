####################################################################################
## NAT gateway to allow outbound connection on a centralized and scalable appliance
####################################################################################
moved {
  from = module.cert_ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound["cert-ci-jenkins-io-vnet-controller"]
  to   = module.cert_ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.cert_ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound["cert-ci-jenkins-io-vnet-ephemeral-agents"]
  to   = module.cert_ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound[1]
}
module "cert_ci_jenkins_io_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "cert-ci-jenkins-io-outbound"
  resource_group_name = azurerm_virtual_network.cert_ci_jenkins_io.resource_group_name
  vnet_name           = azurerm_virtual_network.cert_ci_jenkins_io.name
  subnet_ids = [
    azurerm_subnet.cert_ci_jenkins_io_controller.id,
    azurerm_subnet.cert_ci_jenkins_io_ephemeral_agents.id,
  ]
}
moved {
  from = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["cert-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"]
  to   = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["public-jenkins-sponsorship-vnet-ci_jenkins_io_agents"]
  to   = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[1]
}
moved {
  from = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["public-jenkins-sponsorship-vnet-ci_jenkins_io_kubernetes"]
  to   = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[2]
}
module "cert_ci_jenkins_io_outbound_sponsorship" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  name                = "cert-ci-jenkins-io-outbound-sponsorship"
  resource_group_name = azurerm_virtual_network.cert_ci_jenkins_io_sponsorship.resource_group_name
  vnet_name           = azurerm_virtual_network.cert_ci_jenkins_io_sponsorship.name
  subnet_ids = [
    azurerm_subnet.cert_ci_jenkins_io_sponsorship_ephemeral_agents.id,
  ]
}
moved {
  from = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-vnet-ephemeral-agents"]
  to   = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound[2]
}
moved {
  from = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-vnet-permanent-agents"]
  to   = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound[1]
}
moved {
  from = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-vnet-controller"]
  to   = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound[0]
}
module "trusted_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "trusted-outbound"
  resource_group_name = azurerm_virtual_network.trusted_ci_jenkins_io.resource_group_name
  vnet_name           = azurerm_virtual_network.trusted_ci_jenkins_io.name
  subnet_ids = [
    azurerm_subnet.trusted_ci_jenkins_io_controller.id,
    azurerm_subnet.trusted_ci_jenkins_io_permanent_agents.id,
    azurerm_subnet.trusted_ci_jenkins_io_ephemeral_agents.id,
  ]
}
moved {
  from = module.trusted_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"]
  to   = module.trusted_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[0]
}
module "trusted_outbound_sponsorship" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  name                = "trusted-outbound-sponsorship"
  resource_group_name = azurerm_virtual_network.trusted_ci_jenkins_io_sponsorship.resource_group_name
  vnet_name           = azurerm_virtual_network.trusted_ci_jenkins_io_sponsorship.name
  subnet_ids = [
    azurerm_subnet.trusted_ci_jenkins_io_sponsorship_ephemeral_agents.id,
  ]
  outbound_ip_count = 3
}
moved {
  from = module.ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound["public-vnet-ci_jenkins_io_controller"]
  to   = module.ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound["public-vnet-ci_jenkins_io_agents"]
  to   = module.ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound[1]
}
module "ci_jenkins_io_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "ci-jenkins-io-outbound"
  resource_group_name = azurerm_virtual_network.public.resource_group_name
  vnet_name           = azurerm_virtual_network.public.name
  subnet_ids = [
    azurerm_subnet.public_vnet_ci_jenkins_io_controller.id,
    azurerm_subnet.public_vnet_ci_jenkins_io_agents.id,
  ]
}
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["public-jenkins-sponsorship-vnet-ci_jenkins_io_agents"]
  to   = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["public-jenkins-sponsorship-vnet-ci_jenkins_io_controller"]
  to   = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[1]
}
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["public-jenkins-sponsorship-vnet-ci_jenkins_io_kubernetes"]
  to   = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[2]
}
module "ci_jenkins_io_outbound_sponsorship" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  name                = "ci-jenkins-io-outbound-sponsorship"
  resource_group_name = azurerm_virtual_network.public_jenkins_sponsorship.resource_group_name
  vnet_name           = azurerm_virtual_network.public_jenkins_sponsorship.name
  subnet_ids = [
    azurerm_subnet.public_jenkins_sponsorship_vnet_ci_jenkins_io_agents.id,
    azurerm_subnet.ci_jenkins_io_controller_sponsorship.id,
    azurerm_subnet.ci_jenkins_io_kubernetes_sponsorship.id,
  ]

  outbound_ip_count = 2
}
moved {
  from = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound["privatek8s-tier"]
  to   = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound["privatek8s-release-tier"]
  to   = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound[1]
}
moved {
  from = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound["private-vnet-data-tier"]
  to   = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound[2]
}
moved {
  from = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound["privatek8s-infraci-ctrl-tier"]
  to   = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound[3]
}

module "privatek8s_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "privatek8s-outbound"
  resource_group_name = azurerm_virtual_network.private.resource_group_name
  vnet_name           = azurerm_virtual_network.private.name
  subnet_ids = [
    azurerm_subnet.privatek8s_tier.id,
    azurerm_subnet.privatek8s_release_tier.id,
    azurerm_subnet.private_vnet_data_tier.id,
    azurerm_subnet.privatek8s_infra_ci_controller_tier.id,
  ]
}
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["infra-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"]
  to   = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["infra-ci-jenkins-io-sponsorship-vnet-packer-builds"]
  to   = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[1]
}
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["infra-ci-jenkins-io-sponsorship-vnet-kubernetes-agents"]
  to   = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[2]
}
module "infra_ci_outbound_sponsorship" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  name                = "infra-ci-outbound-sponsorship"
  resource_group_name = azurerm_virtual_network.infra_ci_jenkins_io_sponsorship.resource_group_name
  vnet_name           = azurerm_virtual_network.infra_ci_jenkins_io_sponsorship.name
  subnet_ids = [
    azurerm_subnet.infra_ci_jenkins_io_sponsorship_ephemeral_agents.id,
    azurerm_subnet.infra_ci_jenkins_io_sponsorship_packer_builds.id,
    azurerm_subnet.infra_ci_jenkins_io_kubernetes_agent_sponsorship.id,
  ]

  outbound_ip_count = 2
}
moved {
  from = module.publick8s_outbound.azurerm_subnet_nat_gateway_association.outbound["publick8s-tier"]
  to   = module.publick8s_outbound.azurerm_subnet_nat_gateway_association.outbound[0]
}
module "publick8s_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "publick8s-outbound"
  resource_group_name = azurerm_virtual_network.public.resource_group_name
  vnet_name           = azurerm_virtual_network.public.name
  subnet_ids = [
    azurerm_subnet.publick8s_tier.id,
  ]
}
