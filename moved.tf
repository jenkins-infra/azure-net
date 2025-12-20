moved {
  from = azurerm_dns_cname_record.jenkinsio_customs["pkg.origin"]
  to   = azurerm_dns_cname_record.jenkinsio_target_public_new_publick8s["pkg.origin"]
}
