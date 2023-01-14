# TODO: import as resource
data "azurerm_resource_group" "proddns_jenkinsio" {
  name = "proddns_jenkinsio"
}

# TODO: import as resource
data "azurerm_dns_zone" "jenkinsio" {
  name = "jenkins.io"
}

resource "azurerm_dns_zone" "child_zones" {
  for_each = local.lets_encrypt_dns_challenged_domains

  name = each.key
  # Use the same resource group for all DNS zones
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name

  tags = local.default_tags
}

# create DNS record of type NS for child-zone in the parent zone (to allow propagation of DNS records)
resource "azurerm_dns_ns_record" "child_zone_ns_records" {
  for_each = local.lets_encrypt_dns_challenged_domains

  name                = trimsuffix(each.key, ".jenkins.io") # only the flat name not the fqdn
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60

  records = azurerm_dns_zone.child_zones[each.key].name_servers
}

resource "azuread_application" "letsencrypt_dns_challenges" {
  for_each = { for key, value in local.lets_encrypt_dns_challenged_domains : key => value if value == "service_principal" }

  display_name = replace(each.key, ".", "_")
  owners       = [data.azuread_client_config.current.object_id]
  tags         = [for key, value in local.default_tags : "${key}:${value}"]

  web {
    homepage_url = "https://github.com/jenkins-infra/azure-net"
  }
}

resource "azuread_service_principal" "child_zone_service_principals" {
  for_each = { for key, value in local.lets_encrypt_dns_challenged_domains : key => value if value == "service_principal" }

  application_id = azuread_application.letsencrypt_dns_challenges[each.key].application_id
}

resource "azuread_service_principal_password" "child_zone_service_principal_passwords" {
  for_each = { for key, value in local.lets_encrypt_dns_challenged_domains : key => value if value == "service_principal" }

  display_name         = "Service Principal secret for ${each.key} Let's Encrypt DNS-01 challenges"
  service_principal_id = azuread_service_principal.child_zone_service_principals[each.key].object_id
}

resource "azurerm_role_assignment" "child_zone_service_principal_assignements" {
  for_each = { for key, value in local.lets_encrypt_dns_challenged_domains : key => value if value == "service_principal" }

  scope                = azurerm_dns_zone.child_zones[each.key].id
  role_definition_name = "DNS Zone Contributor" # Predefined standard role in Azure
  principal_id         = azuread_service_principal.child_zone_service_principals[each.key].id
}
