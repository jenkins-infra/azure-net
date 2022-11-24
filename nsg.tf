## Network Security Groups
resource "azurerm_network_security_group" "prod_public_apptier" {
  name                = "prod-jenkins-public-vnet-apptier"
  location            = var.location
  resource_group_name = azurerm_resource_group.prod_public.name

  # Inbound rules
  security_rule {
    name                   = "allow-http-inbound"
    priority               = 100
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "80"
  }
  security_rule {
    name                   = "allow-https-inbound"
    priority               = 101
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "443"
  }
  security_rule {
    name                   = "allow-ldap-inbound"
    priority               = 102
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "636"
  }
  security_rule {
    name                       = "allow-rsyncd-inbound"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "873"
    source_address_prefixes    = var.whitelist_ips
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-public-ssh-inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = azurerm_virtual_network.prod_public.address_space
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
    source_address_prefixes    = azurerm_virtual_network.prod_private.address_space
    destination_address_prefix = "*"
  }

  # Outbound rules
  security_rule {
    name                         = "allow-puppet-outbound"
    priority                     = 2100
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "8140"
    destination_port_range       = "*"
    source_address_prefix        = "*"
    destination_address_prefixes = azurerm_virtual_network.prod_private.address_space
  }
  security_rule {
    name                       = "allow-https-outbound"
    priority                   = 2101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "443"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.default_tags
}
