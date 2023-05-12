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

# CNAME record for release.ci.jenkins.io, accessible only via the private VPN
resource "azurerm_dns_cname_record" "release-ci-jenkins-io" {
  name                = "release.ci"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  record              = "private.privatek8s.jenkins.io"

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
