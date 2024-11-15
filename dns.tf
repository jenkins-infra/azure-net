# TODO: import as resource
data "azurerm_resource_group" "proddns_jenkinsio" {
  name = "proddns_jenkinsio"
}

# TODO: import as resource
data "azurerm_resource_group" "proddns_jenkinsci" {
  name = "proddns_jenkinsci"
}

resource "azurerm_resource_group" "proddns_jenkinsisthewayio" {
  name     = "proddns_jenkinsisthewayio"
  location = "East US 2"
}

# TODO: import as resource
data "azurerm_dns_zone" "jenkinsio" {
  name                = "jenkins.io"
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
}

# TODO: import as resource
data "azurerm_dns_zone" "jenkinsciorg" {
  name                = "jenkins-ci.org"
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsci.name
}

resource "azurerm_dns_zone" "jenkinsistheway_io" {
  name                = "jenkinsistheway.io"
  resource_group_name = azurerm_resource_group.proddns_jenkinsisthewayio.name
}

# NS records pointing to DigitalOcean name servers to delegate do.jenkins.io to them
resource "azurerm_dns_ns_record" "do_jenkins_io" {
  name                = "do"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60

  records = ["ns1.digitalocean.com", "ns2.digitalocean.com", "ns3.digitalocean.com"]

  tags = local.default_tags
}

# NS records pointing to AWS Route53 name servers to delegate aws.ci.jenkins.io to them
locals {
  # Tracked by updatecli, easier to use a string split as a list by Terraform
  aws_route53_nameservers_awscijenkinsio = "ns-1378.awsdns-44.org ns-1925.awsdns-48.co.uk ns-508.awsdns-63.com ns-592.awsdns-10.net"
}
resource "azurerm_dns_ns_record" "aws_ci_jenkins_io" {
  name                = "aws.ci"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60

  records = split(" ", local.aws_route53_nameservers_awscijenkinsio)

  tags = local.default_tags
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
  owners       = [data.azuread_service_principal.terraform-azure-net-production.object_id]
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
  owners                       = [data.azuread_service_principal.terraform-azure-net-production.object_id]

  client_id = azuread_application.letsencrypt_dns_challenges[each.key].client_id
}

resource "azuread_application_password" "child_zone_app_passwords" {
  for_each = { for key, value in local.lets_encrypt_dns_challenged_domains : key => value if value != "" }

  display_name   = "${each.key}-tf-managed"
  application_id = azuread_application.letsencrypt_dns_challenges[each.key].id
  end_date       = each.value
}

resource "azurerm_role_assignment" "child_zone_service_principal_assignements" {
  for_each = { for key, value in local.lets_encrypt_dns_challenged_domains : key => value if value != "" }

  scope                = azurerm_dns_zone.child_zones[each.key].id
  role_definition_name = "DNS Zone Contributor" # Predefined standard role in Azure
  principal_id         = azuread_service_principal.child_zone_service_principals[each.key].object_id
}
