variable "base_name" {
  type        = string
  description = "Base name of the Resource Group and its associated objects"
}

variable "use_existing_rg" {
  type        = bool
  description = "Should we search (and use) an existing Resource Group named 'var.base_name' instead of create it?"
  default     = false
}

variable "custom_vnet_name" {
  type        = string
  description = "Use this custom name for the virtual network instead of generating one."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Collection of key + values tags"
}

variable "location" {
  type        = string
  description = "Azure Region Location"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "List of CIDRs (IPv4 and/or IPv6) for the Virtual Network address space"
}

variable "subnets" {
  type = list(object({
    name                                          = string,
    address_prefixes                              = list(string),
    service_endpoints                             = list(string),
    private_endpoint_network_policies             = string,
    private_link_service_network_policies_enabled = bool,
    use_default_outbound_access                   = bool,
    delegations = map(object({
      service_delegations = set(object({
        name    = string
        actions = list(string)
      }))
    }))
  }))
  description = "List of subnets provided as objects with 'subnet_name_suffix' as a string, address_prefixes as a list of CIDRs contained in var.vnet_address_space and service_endpoints as a list of string"
}

variable "peered_vnets" {
  type        = map(string)
  description = "Map of virtual networks to peer with (map keys are vnet names and map values are vnet IDs)"
  default     = {}
}

variable "gateway_name" {
  type        = string
  description = "Name of the NAT gateway (and associated Public IP) if the vnet should use one"
  default     = ""
}

variable "gateway_subnets_exclude" {
  type        = list(string)
  description = "Exclude these subnets from the gateway (default is to associate all subnets. This variable is to support a legacy case of the old publick8s cluster network config)"
  default     = []
}

variable "outbound_ip_count" {
  type        = number
  description = "Number of outbound IPs to use."
  default     = 1
}
