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
####################################################################################
## NAT gateway to allow outbound connection on a centralized and scalable appliance
####################################################################################
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
}

####################################################################################
## NAT gateway to allow outbound connection on a centralized and scalable appliance
####################################################################################
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
  ]
}

module "privatek8s_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "privatek8s-outbound"
  resource_group_name = azurerm_virtual_network.private.resource_group_name
  vnet_name           = azurerm_virtual_network.private.name
  subnet_names = [
    ## Commented for phase 1 of https://github.com/jenkins-infra/helpdesk/issues/3908#issuecomment-1905856702
    # azurerm_subnet.privatek8s_tier.name,
  ]
}

module "publick8s_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "publick8s-outbound"
  resource_group_name = azurerm_virtual_network.public.resource_group_name
  vnet_name           = azurerm_virtual_network.public.name
  subnet_names = [
    ## ## Commented for phase 1 of https://github.com/jenkins-infra/helpdesk/issues/3908#issuecomment-1905856702
    # azurerm_subnet.publick8s_tier.name,
  ]
}
