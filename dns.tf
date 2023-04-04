# TODO: import as resource
data "azurerm_resource_group" "proddns_jenkinsio" {
  name = "proddns_jenkinsio"
}

# TODO: import as resource
data "azurerm_dns_zone" "jenkinsio" {
  name                = "jenkins.io"
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
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

  tags = local.default_tags
}

resource "azuread_application" "letsencrypt_dns_challenges" {
  for_each = { for key, value in local.lets_encrypt_dns_challenged_domains : key => value if value != "" }

  display_name = "letsencrypt-${each.key}"
  owners       = [data.azuread_service_principal.terraform-azure-net-production.id]
  tags         = [for key, value in local.default_tags : "${key}:${value}"]

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
  }

  web {
    homepage_url = "https://github.com/jenkins-infra/azure-net"
  }
}

resource "azuread_service_principal" "child_zone_service_principals" {
  for_each = { for key, value in local.lets_encrypt_dns_challenged_domains : key => value if value != "" }

  app_role_assignment_required = false
  owners                       = [data.azuread_service_principal.terraform-azure-net-production.id]

  application_id = azuread_application.letsencrypt_dns_challenges[each.key].application_id
}

resource "azuread_application_password" "child_zone_app_passwords" {
  for_each = { for key, value in local.lets_encrypt_dns_challenged_domains : key => value if value != "" }

  display_name          = "${each.key}-tf-managed"
  application_object_id = azuread_application.letsencrypt_dns_challenges[each.key].id
  end_date              = each.value
}

resource "azurerm_role_assignment" "child_zone_service_principal_assignements" {
  for_each = { for key, value in local.lets_encrypt_dns_challenged_domains : key => value if value != "" }

  scope                = azurerm_dns_zone.child_zones[each.key].id
  role_definition_name = "DNS Zone Contributor" # Predefined standard role in Azure
  principal_id         = azuread_service_principal.child_zone_service_principals[each.key].id
}

# CNAME record for artifact-caching-proxy on Azure
resource "azurerm_dns_cname_record" "target" {
  name                = "repo.azure"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  record              = "public.publick8s.jenkins.io"

  tags = local.default_tags
}

# CNAME record for github-comment-ops GitHub App
resource "azurerm_dns_cname_record" "webhook-github-comment-ops" {
  name                = "webhook-github-comment-ops"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  record              = "public.privatek8s.jenkins.io"

  tags = local.default_tags
}

# TXT record to verify jenkinsci-transfer GitHub org (https://github.com/jenkins-infra/helpdesk/issues/3448)
resource "azurerm_dns_txt_record" "jenkinsci-transfer-github-verification" {
  name                = "_github-challenge-jenkinsci-transfer-org.www"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300

  record {
    value = "b4df95a7b9"
  }

  tags = local.default_tags
}

# CNAME record for release.ci.jenkins.io, accessible only via the private VPN
resource "azurerm_dns_cname_record" "release-ci-jenkins-io" {
  name                = "release.ci"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  record              = "private.privatek8s.jenkins.io"

  tags = local.default_tags
}

# A record for cert.ci.jenkins.io, accessible only via the private VPN
# TODO: migrate this record to https://github.com/jenkins-infra/azure/blob/3aae66f0443c766301ae81f4d2aac5cec6032935/cert.ci.jenkins.io.tf#L14
# once the associated resource will be imported and managed in jenkins-infra/azure (Public IP, VM, etc.)
resource "azurerm_dns_a_record" "cert-ci-jenkins-io" {
  name                = "@"
  zone_name           = azurerm_dns_zone.child_zones["cert.ci.jenkins.io"].name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  records             = ["10.0.2.252"]

  tags = local.default_tags
}
