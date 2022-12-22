####################################################################################
## Network Security Groups for Private subnets
####################################################################################
resource "azurerm_network_security_group" "private_dmz" {
  name                = "${azurerm_virtual_network.private.name}-dmz"
  location            = azurerm_resource_group.private.location
  resource_group_name = azurerm_resource_group.private.name

  # No security rule: using 'azurerm_network_security_rule' to allow composition across files
  tags = local.default_tags
}

resource "azurerm_subnet_network_security_group_association" "private_dmz" {
  subnet_id                 = azurerm_subnet.dmz.id
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
  source_address_prefixes     = azurerm_virtual_network.private.address_space
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.private.name
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
  destination_address_prefixes = azurerm_virtual_network.private.address_space
  resource_group_name          = azurerm_resource_group.private.name
  network_security_group_name  = azurerm_network_security_group.private_dmz.name
}

####################################################################################
## Network Security Groups for Public subnets
####################################################################################
resource "azurerm_network_security_group" "public_apptier" {
  name                = "${azurerm_resource_group.public.name}-nsg-apptier"
  location            = azurerm_resource_group.public.location
  resource_group_name = azurerm_resource_group.public.name

  # No security rule: using 'azurerm_network_security_rule' to allow composition across files
  tags = local.default_tags

  ## Inbound rules

  #tfsec:ignore:azure-network-no-public-ingress
  security_rule {
    name                       = "allow-http-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  #tfsec:ignore:azure-network-no-public-ingress
  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  #tfsec:ignore:azure-network-no-public-ingress
  security_rule {
    name                       = "allow-ldap-inbound"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "636"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                   = "allow-rsyncd-inbound"
    priority               = 103
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "873"
    # 52.202.51.185: pkg.origin.jenkins.io
    # TODO: replace by the object reference data when all DNS entries will be imported
    source_address_prefixes    = ["52.202.51.185/32"]
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-private-ssh-inbound"
    priority                   = 4001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = azurerm_virtual_network.private.address_space
    destination_address_prefix = "*"
  }

  ## Outbound rules
  security_rule {
    name                         = "allow-puppet-outbound"
    priority                     = 2100
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "8140"
    source_address_prefix        = "*"
    destination_address_prefixes = azurerm_virtual_network.private.address_space
  }
  #tfsec:ignore:azure-network-no-public-egress
  security_rule {
    name                       = "allow-https-outbound"
    priority                   = 2101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

## TODO
# resource "azurerm_subnet_network_security_group_association" "public_apptier" {
#   subnet_id                 = # To Be Determined
#   network_security_group_id = azurerm_network_security_group.public_apptier.id
# }
