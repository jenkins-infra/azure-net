####################################################################################
## NAT gateway to allow outbound connection on a centralized and scalable appliance
####################################################################################
module "cert_ci_jenkins_io_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "cert-ci-jenkins-io-outbound"
  resource_group_name = azurerm_virtual_network.cert_ci_jenkins_io.resource_group_name
  vnet_name           = azurerm_virtual_network.cert_ci_jenkins_io.name
  subnet_names = [
    azurerm_subnet.cert_ci_jenkins_io_controller.name,
    azurerm_subnet.cert_ci_jenkins_io_ephemeral_agents.name,
  ]
}
module "cert_ci_jenkins_io_outbound_sponsorship" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  name                = "cert-ci-jenkins-io-outbound-sponsorship"
  resource_group_name = azurerm_virtual_network.cert_ci_jenkins_io_sponsorship.resource_group_name
  vnet_name           = azurerm_virtual_network.cert_ci_jenkins_io_sponsorship.name
  subnet_names = [
    azurerm_subnet.cert_ci_jenkins_io_sponsorship_ephemeral_agents.name,
  ]
}

module "trusted_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "trusted-outbound"
  resource_group_name = azurerm_virtual_network.trusted_ci_jenkins_io.resource_group_name
  vnet_name           = azurerm_virtual_network.trusted_ci_jenkins_io.name
  subnet_names = [
    azurerm_subnet.trusted_ci_jenkins_io_controller.name,
    azurerm_subnet.trusted_ci_jenkins_io_permanent_agents.name,
    azurerm_subnet.trusted_ci_jenkins_io_ephemeral_agents.name,
  ]
}
module "trusted_outbound_sponsorship" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  name                = "trusted-outbound-sponsorship"
  resource_group_name = azurerm_virtual_network.trusted_ci_jenkins_io_sponsorship.resource_group_name
  vnet_name           = azurerm_virtual_network.trusted_ci_jenkins_io_sponsorship.name
  subnet_names = [
    azurerm_subnet.trusted_ci_jenkins_io_sponsorship_ephemeral_agents.name,
  ]
  outbound_ip_count = 3
}

module "ci_jenkins_io_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "ci-jenkins-io-outbound"
  resource_group_name = azurerm_virtual_network.public.resource_group_name
  vnet_name           = azurerm_virtual_network.public.name
  subnet_names = [
    azurerm_subnet.public_vnet_ci_jenkins_io_controller.name,
    azurerm_subnet.public_vnet_ci_jenkins_io_agents.name,
  ]
}
module "ci_jenkins_io_outbound_sponsorship" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  name                = "ci-jenkins-io-outbound-sponsorship"
  resource_group_name = azurerm_virtual_network.public_jenkins_sponsorship.resource_group_name
  vnet_name           = azurerm_virtual_network.public_jenkins_sponsorship.name
  subnet_names = [
    azurerm_subnet.public_jenkins_sponsorship_vnet_ci_jenkins_io_agents.name,
    azurerm_subnet.ci_jenkins_io_controller_sponsorship.name,
    azurerm_subnet.ci_jenkins_io_kubernetes_sponsorship.name,
  ]

  outbound_ip_count = 2
}

module "privatek8s_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "privatek8s-outbound"
  resource_group_name = azurerm_virtual_network.private.resource_group_name
  vnet_name           = azurerm_virtual_network.private.name
  subnet_names = [
    azurerm_subnet.privatek8s_tier.name,
    azurerm_subnet.privatek8s_release_tier.name,
    azurerm_subnet.private_vnet_data_tier.name,
    azurerm_subnet.privatek8s_infra_ci_controller_tier.name,
  ]
}

module "infra_ci_outbound_sponsorship" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  name                = "infra-ci-outbound-sponsorship"
  resource_group_name = azurerm_virtual_network.infra_ci_jenkins_io_sponsorship.resource_group_name
  vnet_name           = azurerm_virtual_network.infra_ci_jenkins_io_sponsorship.name
  subnet_names = [
    azurerm_subnet.infra_ci_jenkins_io_sponsorship_ephemeral_agents.name,
    azurerm_subnet.infra_ci_jenkins_io_sponsorship_packer_builds.name,
    azurerm_subnet.infra_ci_jenkins_io_kubernetes_agent_sponsorship.name,
  ]

  outbound_ip_count = 2
}

module "publick8s_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "publick8s-outbound"
  resource_group_name = azurerm_virtual_network.public.resource_group_name
  vnet_name           = azurerm_virtual_network.public.name
  subnet_names = [
    azurerm_subnet.publick8s_tier.name,
  ]
}
