locals {
  rg_name   = var.use_existing_rg ? data.azurerm_resource_group.vnet_rg[0].name : azurerm_resource_group.vnet_rg[0].name
  vnet_name = length(var.custom_vnet_name) > 0 ? var.custom_vnet_name : "${var.base_name}-vnet"
  gateway_subnet_ids = var.gateway_name == "" ? {} : {
    for subnet, subnet_config in azurerm_subnet.vnet_subnets :
    subnet => subnet_config.id if !contains(var.gateway_subnets_exclude, subnet)
  }
}
