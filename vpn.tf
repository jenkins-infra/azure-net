resource "azurerm_resource_group" "vpn" {
  name     = "vpn"
  location = var.location
  tags     = local.default_tags
}

# Dedicated subnet in the private vnet
resource "azurerm_subnet" "vpn" {
  name                 = "${azurerm_virtual_network.private.name}-vpn"
  resource_group_name  = azurerm_resource_group.private.name
  virtual_network_name = azurerm_virtual_network.private.name
  address_prefixes     = ["10.248.0.0/28"]
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
  name                = local.vpn.shorthostname
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  records             = [azurerm_public_ip.public.ip_address]
  tags                = local.default_tags
}

resource "azurerm_network_interface" "main" {
  name                = "${azurerm_virtual_network.private.name}-vpn-nic-main"
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
  name                = "${azurerm_virtual_network.private.name}-vpn-nic-internal"
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

// For main interface (not internal!)
resource "azurerm_network_security_group" "main" {
  name                = "${azurerm_resource_group.vpn.name}-nsg-main"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name
  // TODO:
  // Allow only SSH from specific IPs
  // Allow openvpn from all IPs
  ## Inbound rules
  security_rule {
    name                       = "allowed-ssh-ips-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = values(local.vpn.allowed_ips)
    destination_address_prefix = azurerm_network_interface.main.private_ip_address # "*"?
  }

  ## Outbound rules
  #tfsec:ignore:azure-network-no-public-egress
  security_rule {
    name                       = "allow-http-outbound"
    priority                   = 2000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  #tfsec:ignore:azure-network-no-public-egress
  security_rule {
    name                       = "allow-https-outbound"
    priority                   = 2001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  #tfsec:ignore:azure-network-no-public-egress
  security_rule {
    name                         = "allow-puppet-outbound"
    priority                     = 2002
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "8140"
    source_address_prefix        = "*"
    destination_address_prefixes = values(local.vpn.puppet_ips)
  }

  tags = local.default_tags
}

// TODO: nsg for the internal NIC, check if existing one?
// deny all, authorize 5432 for database only for ex, API k8s of privatek8s, ssh rebond


resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_linux_virtual_machine" "vpn" {
  name                = "${azurerm_virtual_network.private.name}-vpn"
  resource_group_name = azurerm_resource_group.vpn.name
  location            = azurerm_resource_group.vpn.location
  size                = "Standard_B1s"
  admin_username      = local.vpn.username
  network_interface_ids = [
    azurerm_network_interface.main.id,
    azurerm_network_interface.internal.id,
  ]

  admin_ssh_key {
    username = local.vpn.username
    # Private key stored as AZURE_NET_VPN_PRIVATE_KEY in https://github.com/jenkins-infra/charts-secrets/blob/main/config/infra.ci.jenkins.io/jenkins-secrets.yaml
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3mnu4alSfeWuKBDQjVZn0sSogh5Cf31SlV3CbbHhjmJ9ZKIe4KKGRNhgtrVosDwQ4QeW8bE2QwzExII6UOZQ8uEeLJHpjHR6DJNFCmUM24dvZD5eSTdLi89JcY1EGAIsVue+a7vdPDadPWQLb8eiYBuGfA4ydmFTIJEoCsNDZk6bOYyFxQPnYgKIuw9qxQhMvq55sMch+Fh+eMO4Sc0I5V0MMDl/UaC3hbpT9gegqwMw6hPC0OMhpEe3b/G/cW0buQf7pXSW4RN7ukyoeTTYXmjVKMB5K5qLAznSepe+p4qkGNdfQd1BcKNd72L8jEfc/Nbs8ZP34PHwsjFSTDC1WJWrwhzxCLinJ+WisB4JyWoY8S7ziOi4Rb7sevneYFjjVcY1kxvsM+dnzQxleRlPibV/1kzNtH/pqLFIX8eM+m6lTDgc6phhtQnWlPsLyrKbILAI6wP1MHvwz9SaKqKFXx+4Dnrz3my3L9U8v/oBCbHjhjjFSW3jT1ZAsXe553PmF7xYoFnSxrbXwjuVSfHrS2KEldfB116Acw5IMSTre+q7woP7XvocLZEi9AOE/+nQjL0R7XOCXI8ODOfk9BSQ1EOqyf1ONDIVf3ugAKoEQ22lBt8pLdFZjY2Mc5UbMzOT/MUYgLI/zKGg8+XGRXlYelEivMf3PBrit9FVucHhyfQ== jenkins-infra-team@googlegroups.com"
  }

  user_data = base64encode(templatefile("./.shared-tools/terraform/cloudinit.tftpl", { hostname = join(".", [local.vpn.shorthostname, data.azurerm_dns_zone.jenkinsio.name]) }))

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    // TODO: use fixed version + updatecli manifest if it recreates the VM
    # az vm image list --all --publisher="Canonical" --sku="22_04-lts-gen2" --offer="0001-com-ubuntu-server-jammy"
    version = "22.04.202211160"
  }

  # identity {
  #   type = "SystemAssigned"
  # }

  tags = local.default_tags
}

output "vpn_public_ip_address" {
  value = azurerm_public_ip.public.ip_address
}
