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
