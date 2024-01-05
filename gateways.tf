####################################################################################
## NAT gateway to allow outbound connection on a centralized and scalable appliance
####################################################################################
resource "azurerm_public_ip" "cert_ci_jenkins_io_outbound" {
  name                = "cert-ci-jenkins-io-outbound"
  location            = azurerm_virtual_network.cert_ci_jenkins_io.location
  resource_group_name = azurerm_virtual_network.cert_ci_jenkins_io.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_nat_gateway" "cert_ci_jenkins_io_outbound" {
  name                = "cert-ci-jenkins-io-outbound"
  location            = azurerm_virtual_network.cert_ci_jenkins_io.location
  resource_group_name = azurerm_virtual_network.cert_ci_jenkins_io.resource_group_name
  sku_name            = "Standard"
}
resource "azurerm_nat_gateway_public_ip_association" "cert_ci_jenkins_io_outbound" {
  nat_gateway_id       = azurerm_nat_gateway.cert_ci_jenkins_io_outbound.id
  public_ip_address_id = azurerm_public_ip.cert_ci_jenkins_io_outbound.id
}
resource "azurerm_subnet_nat_gateway_association" "cert_ci_jenkins_io_outbound_controller" {
  subnet_id      = azurerm_subnet.cert_ci_jenkins_io_controller.id
  nat_gateway_id = azurerm_nat_gateway.cert_ci_jenkins_io_outbound.id
}
resource "azurerm_subnet_nat_gateway_association" "cert_ci_jenkins_io_outbound_ephemeral_agents" {
  subnet_id      = azurerm_subnet.cert_ci_jenkins_io_ephemeral_agents.id
  nat_gateway_id = azurerm_nat_gateway.cert_ci_jenkins_io_outbound.id
}
####################################################################################
## NAT gateway to allow outbound connection on a centralized and scalable appliance
####################################################################################
resource "azurerm_public_ip" "trusted_outbound" {
  name                = "trusted-outbound"
  location            = azurerm_virtual_network.trusted_ci_jenkins_io.location
  resource_group_name = azurerm_virtual_network.trusted_ci_jenkins_io.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_nat_gateway" "trusted_outbound" {
  name                = "trusted-outbound"
  location            = azurerm_virtual_network.trusted_ci_jenkins_io.location
  resource_group_name = azurerm_virtual_network.trusted_ci_jenkins_io.resource_group_name
  sku_name            = "Standard"
}
resource "azurerm_nat_gateway_public_ip_association" "trusted_outbound" {
  nat_gateway_id       = azurerm_nat_gateway.trusted_outbound.id
  public_ip_address_id = azurerm_public_ip.trusted_outbound.id
}
resource "azurerm_subnet_nat_gateway_association" "trusted_outbound_controller" {
  subnet_id      = azurerm_subnet.trusted_ci_jenkins_io_controller.id
  nat_gateway_id = azurerm_nat_gateway.trusted_outbound.id
}
resource "azurerm_subnet_nat_gateway_association" "trusted_outbound_permanent_agents" {
  subnet_id      = azurerm_subnet.trusted_ci_jenkins_io_permanent_agents.id
  nat_gateway_id = azurerm_nat_gateway.trusted_outbound.id
}
resource "azurerm_subnet_nat_gateway_association" "trusted_outbound_ephemeral_agents" {
  subnet_id      = azurerm_subnet.trusted_ci_jenkins_io_ephemeral_agents.id
  nat_gateway_id = azurerm_nat_gateway.trusted_outbound.id
}
