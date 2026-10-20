####################################################################################
## Network Security Groups for Private subnets
####################################################################################
resource "azurerm_network_security_group" "private_dmz" {
  name                = "${module.private_vnet.vnet_name}-dmz"
  location            = var.location
  resource_group_name = module.private_vnet.vnet_rg_name

  # No security rule: using 'azurerm_network_security_rule' to allow composition across files

  tags = local.default_tags
}

resource "azurerm_subnet_network_security_group_association" "private_dmz" {
  subnet_id                 = module.private_vnet.subnets["private-vnet-dmz"]
  network_security_group_id = azurerm_network_security_group.private_dmz.id
}

resource "azurerm_network_security_rule" "deny_all_from_vnet" {
  name = "deny-all-from-vnet"
  # Priority should be the highest value possible (lower than the default 65000 "default" rules not overidable) but higher than the other security rules
  # ref. https://github.com/hashicorp/terraform-provider-azurerm/issues/11137 and https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule#priority
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = module.private_vnet.vnet_address_space
  destination_address_prefix  = "*"
  resource_group_name         = module.private_vnet.vnet_rg_name
  network_security_group_name = azurerm_network_security_group.private_dmz.name
}
resource "azurerm_network_security_rule" "deny_all_to_vnet" {
  name = "deny-all-to-vnet"
  # Priority should be the highest value possible (lower than the default 65000 "default" rules not overidable) but higher than the other security rules
  # ref. https://github.com/hashicorp/terraform-provider-azurerm/issues/11137 and https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule#priority
  priority                     = 4095
  direction                    = "Outbound"
  access                       = "Deny"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefixes = module.private_vnet.vnet_address_space
  resource_group_name          = module.private_vnet.vnet_rg_name
  network_security_group_name  = azurerm_network_security_group.private_dmz.name
}
