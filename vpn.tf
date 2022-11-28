resource "azurerm_resource_group" "vpn" {
  name     = "prod-vpn"
  location = var.location
  tags     = local.default_tags
}

# Dedicated subnet in the private vnet
resource "azurerm_subnet" "vpn" {
  name                 = "${azurerm_virtual_network.prod_private.name}-vpn"
  resource_group_name  = azurerm_resource_group.vpn.name
  virtual_network_name = azurerm_virtual_network.prod_private.name
  address_prefixes     = ["10.244.0.0/28"]
}

resource "azurerm_public_ip" "public" {
  name                = "${azurerm_resource_group.vpn.name}-public-ip"
  resource_group_name = azurerm_resource_group.vpn.name
  location            = azurerm_resource_group.vpn.location
  allocation_method   = "Static"
  sku                 = "Basic"
  tags                = local.default_tags
}

resource "azurerm_dns_a_record" "vpn" {
  name                = local.vpn_subdomain
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  records             = [azurerm_public_ip.public.ip_address]
  tags                = local.default_tags
}

resource "azurerm_network_interface" "main" {
  name                = "${azurerm_virtual_network.prod_private.name}-vpn-nic-main"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name

  ip_configuration {
    name                          = "main"
    subnet_id                     = azurerm_subnet.vpn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public.id
  }

  tags = local.default_tags
}

resource "azurerm_network_interface" "internal" {
  name                = "${azurerm_virtual_network.prod_private.name}-vpn-nic-internal"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vpn.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.default_tags
}

# From https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/virtual-machines/linux/public-ip/main.tf
resource "azurerm_network_security_group" "webserver" {
  name                = "${azurerm_resource_group.vpn.name}-tls-webserver"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "tls"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = azurerm_network_interface.main.private_ip_address
  }
  tags = local.default_tags
}

# Association should be linked to azurerm_network_interface.main instead of internal???
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.internal.id
  network_security_group_id = azurerm_network_security_group.webserver.id
}

resource "azurerm_linux_virtual_machine" "vpn" {
  name                = "${azurerm_virtual_network.prod_private.name}-vpn"
  resource_group_name = azurerm_resource_group.vpn.name
  location            = azurerm_resource_group.vpn.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.main.id,
    azurerm_network_interface.internal.id,
  ]

  admin_ssh_key {
    username   = "jenkins-infra-team"
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGFrPRIlP8qplANgNa3IO5c1gh0ZqNNj17RZeYcm+Jcb jenkins-infra-team@googlegroups.com"
  }

  user_data = base64encode(templatefile("./vpn-cloudinit.tftpl", { hostname = join(".", local.vpn_subdomain, data.azurerm_dns_zone.jenkinsio.name) }))

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  # identity {
  #   type = "SystemAssigned"
  # }

  tags = local.default_tags
}

output "vpn_public_ip_address" {
  value = azurerm_public_ip.public.ip_address
}
