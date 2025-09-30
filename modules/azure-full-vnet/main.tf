####################################################################################
## Virtual Network
####################################################################################
resource "azurerm_resource_group" "vnet_rg" {
  count    = var.use_existing_rg ? 0 : 1
  name     = var.base_name
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "vnet_rg" {
  count = var.use_existing_rg ? 1 : 0
  name  = var.base_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = var.location
  resource_group_name = local.rg_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

####################################################################################
## Virtual Network side object: Subnets / Peerings
####################################################################################
resource "azurerm_subnet" "vnet_subnets" {
  for_each = {
    for index, subnet in var.subnets : subnet.name => subnet
  }
  name                                          = each.key
  resource_group_name                           = local.rg_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.service_endpoints
  private_link_service_network_policies_enabled = try(each.value.private_link_service_network_policies_enabled, true)
  private_endpoint_network_policies             = try(each.value.private_endpoint_network_policies, "Enabled")
  default_outbound_access_enabled               = false

  dynamic "delegation" {
    for_each = each.value.delegations
    content {
      name = delegation.key

      dynamic "service_delegation" {
        for_each = delegation.value.service_delegations
        content {
          name    = service_delegation.value.name
          actions = service_delegation.value.actions
        }
      }
    }
  }
}
resource "azurerm_virtual_network_peering" "vnet_peering" {
  for_each                     = var.peered_vnets
  name                         = "${azurerm_virtual_network.vnet.name}-to-${each.key}"
  resource_group_name          = local.rg_name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = each.value
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

####################################################################################
## NAT gateway
####################################################################################
resource "azurerm_public_ip" "outbound" {
  count               = var.gateway_name == "" ? 0 : 1
  name                = var.gateway_name
  location            = var.location
  resource_group_name = local.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_public_ip" "additional_outbounds" {
  count               = var.gateway_name == "" ? 0 : var.outbound_ip_count - 1 # Substract 1: the principal outbound IP
  name                = format("%s-additional-%d", var.gateway_name, count.index)
  location            = var.location
  resource_group_name = local.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_nat_gateway_public_ip_association" "additional_outbounds" {
  count                = var.gateway_name == "" ? 0 : length(azurerm_public_ip.additional_outbounds)
  nat_gateway_id       = azurerm_nat_gateway.outbound[0].id
  public_ip_address_id = azurerm_public_ip.additional_outbounds[count.index].id
}
resource "azurerm_nat_gateway" "outbound" {
  count               = var.gateway_name == "" ? 0 : 1
  name                = var.gateway_name
  location            = var.location
  resource_group_name = local.rg_name
  sku_name            = "Standard"
}
resource "azurerm_nat_gateway_public_ip_association" "outbound" {
  count                = var.gateway_name == "" ? 0 : 1
  nat_gateway_id       = azurerm_nat_gateway.outbound[0].id
  public_ip_address_id = azurerm_public_ip.outbound[0].id
}
resource "azurerm_subnet_nat_gateway_association" "outbound" {
  for_each       = local.gateway_subnet_ids
  subnet_id      = each.value
  nat_gateway_id = azurerm_nat_gateway.outbound[0].id
}
