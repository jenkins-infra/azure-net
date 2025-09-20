output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "vnet_rg_name" {
  value = local.rg_name
}

output "vnet_address_space" {
  value = azurerm_virtual_network.vnet.address_space
}

output "subnets" {
  value = { for index, subnet in azurerm_subnet.vnet_subnets : subnet.name => subnet.id }
}

output "public_ip_list" {
  value = var.gateway_name == "" ? "" : (var.outbound_ip_count == 1 ? azurerm_public_ip.outbound[0].ip_address : join(",", concat([azurerm_public_ip.outbound[0].ip_address], azurerm_public_ip.additional_outbounds.*.ip_address)))
}
