variable "location" {
  type    = string
  default = "East US 2"
}

variable "whitelist_ips" {
  description = "A list of IP CIDR ranges to allow as clients. Do not use Azure tags like `Internet`."
  # 52.167.253.43: prodgw-publick8s
  # 52.202.51.185: ?
  # 52.177.88.13: prodpublick8s aks-slb-managed-outbound-ip
  default = ["52.167.253.43/32", "52.202.51.185/32", "52.177.88.13/32"]
  type    = list(string)
}
