### A records
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

# A record for the jenkinsistheway.io redirector hosted on publick8s redirecting to stories.jenkins.io
resource "azurerm_dns_a_record" "jenkinsistheway_io" {
  name                = "@"
  zone_name           = azurerm_dns_zone.jenkinsistheway_io.name
  resource_group_name = azurerm_resource_group.proddns_jenkinsisthewayio.name
  ttl                 = 60
  records              = ["20.119.232.75"] # publick8s_public_ipv4_address defined in https://github.com/jenkins-infra/azure/blob/main/publick8s.tf

  tags = merge(local.default_tags, {
    purpose = "Jenkinsistheway.io redirector to stories.jenkins.io"
  })
}

# A record for the jenkinsistheway.io redirector hosted on publick8s redirecting to stories.jenkins.io
resource "azurerm_dns_aaaa_record" "jenkinsistheway_io_ipv6" {
  name                = "@"
  zone_name           = azurerm_dns_zone.jenkinsistheway_io.name
  resource_group_name = azurerm_resource_group.proddns_jenkinsisthewayio.name
  ttl                 = 60
  records              = ["2603:1030:408:7::44"] # publick8s_public_ipv6_address defined in https://github.com/jenkins-infra/azure/blob/main/publick8s.tf

  tags = merge(local.default_tags, {
    purpose = "Jenkinsistheway.io redirector to stories.jenkins.io"
  })
}

### CNAME records
# CNAME records targeting the public-nginx on publick8s cluster
resource "azurerm_dns_cname_record" "target_public_publick8s" {
  # Map of records and corresponding purposes
  for_each = {
    "javadoc"    = "Jenkins Javadoc"
    "repo.azure" = "artifact-caching-proxy on Azure"
    "weekly.ci"  = "Jenkins Weekly demo controller"
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  record              = "public.publick8s.jenkins.io"

  tags = merge(local.default_tags, {
    purpose = each.value
  })
}

# CNAME records targeting the public-nginx on privatek8s cluster
resource "azurerm_dns_cname_record" "target_public_privatek8s" {
  # Map of records and corresponding purposes
  for_each = {
    "webhook-github-comment-ops" = "github-comment-ops GitHub App"
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  record              = "public.privatek8s.jenkins.io"

  tags = merge(local.default_tags, {
    purpose = each.value
  })
}

# CNAME records targeting the private-nginx on publick8s cluster
resource "azurerm_dns_cname_record" "target_private_privatek8s" {
  # Map of records and corresponding purposes
  for_each = {
    "release.ci" = "release.ci.jenkins.io, accessible only via the private VPN"
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  record              = "private.privatek8s.jenkins.io"

  tags = merge(local.default_tags, {
    purpose = each.value
  })
}

# CNAME records targeting the public-nginx on prodpublick8s cluster
# TODO: to be removed after https://github.com/jenkins-infra/helpdesk/issues/3351
resource "azurerm_dns_cname_record" "target_public_prodpublick8s" {
  # Map of records and corresponding purposes
  for_each = {
    "wiki"    = "Static Wiki Confluence export"
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60
  record              = "public.aks.jenkins.io"

  tags = merge(local.default_tags, {
    purpose = each.value
  })
}

### TXT records
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
