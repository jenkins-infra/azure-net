####################################################################################
## NAT gateway to allow outbound connection on a centralized and scalable appliance
####################################################################################
moved {
  from = azurerm_public_ip.cert_ci_jenkins_io_outbound
  to   = module.cert_ci_jenkins_io_outbound.azurerm_public_ip.outbound
}
moved {
  from = azurerm_nat_gateway.cert_ci_jenkins_io_outbound
  to   = module.cert_ci_jenkins_io_outbound.azurerm_nat_gateway.outbound
}
moved {
  from = azurerm_nat_gateway_public_ip_association.cert_ci_jenkins_io_outbound
  to   = module.cert_ci_jenkins_io_outbound.azurerm_nat_gateway_public_ip_association.outbound
}
moved {
  from = azurerm_subnet_nat_gateway_association.cert_ci_jenkins_io_outbound_controller
  to   = module.cert_ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound["cert-ci-jenkins-io-vnet-controller"]
}
moved {
  from = azurerm_subnet_nat_gateway_association.cert_ci_jenkins_io_outbound_ephemeral_agents
  to   = module.cert_ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound["cert-ci-jenkins-io-vnet-ephemeral-agents"]
}
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
####################################################################################
## NAT gateway to allow outbound connection on a centralized and scalable appliance
####################################################################################
moved {
  from = azurerm_public_ip.trusted_outbound
  to   = module.trusted_outbound.azurerm_public_ip.outbound
}
moved {
  from = azurerm_nat_gateway.trusted_outbound
  to   = module.trusted_outbound.azurerm_nat_gateway.outbound
}
moved {
  from = azurerm_nat_gateway_public_ip_association.trusted_outbound
  to   = module.trusted_outbound.azurerm_nat_gateway_public_ip_association.outbound
}
moved {
  from = azurerm_subnet_nat_gateway_association.trusted_outbound_controller
  to   = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-vnet-controller"]
}
moved {
  from = azurerm_subnet_nat_gateway_association.trusted_outbound_ephemeral_agents
  to   = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-vnet-ephemeral-agents"]
}
moved {
  from = azurerm_subnet_nat_gateway_association.trusted_outbound_permanent_agents
  to   = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-vnet-permanent-agents"]
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
