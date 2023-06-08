moved {
  from = azurerm_dns_cname_record.jenkinsio_target_status_incident["accounts"]
  to   = azurerm_dns_cname_record.jenkinsio_target_public_publick8s["accounts"]
}
moved {
  from = azurerm_dns_cname_record.jenkinsciorg_target_status_incident["accounts"]
  to   = azurerm_dns_cname_record.jenkinsciorg_target_public_publick8s["accounts"]
}

### A records
## jenkins.io DNS zone records
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

# A record for the jenkins.io website hosted on prodpublick8s
resource "azurerm_dns_a_record" "jenkins_io" {
  name                = "@"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60
  records             = ["52.167.253.43"] # prodpublick8s IPv4

  tags = merge(local.default_tags, {
    purpose = "Jenkins website"
  })
}

# A record for ldap.jenkins.io pointing to its own public LB IP from prodpublick8s cluster
resource "azurerm_dns_a_record" "ldap_jenkins_io" {
  name                = "ldap"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60
  records             = ["52.184.219.77"] # ldap load balancer IP on prodpublick8s

  tags = merge(local.default_tags, {
    purpose = "Jenkins user authentication service"
  })
}

## jenkinsistheway.io DNS zone records
# A record for the jenkinsistheway.io redirector hosted on publick8s redirecting to stories.jenkins.io
resource "azurerm_dns_a_record" "jenkinsistheway_io" {
  name                = "@"
  zone_name           = azurerm_dns_zone.jenkinsistheway_io.name
  resource_group_name = azurerm_resource_group.proddns_jenkinsisthewayio.name
  ttl                 = 60
  records             = ["20.119.232.75"] # publick8s_public_ipv4_address defined in https://github.com/jenkins-infra/azure/blob/main/publick8s.tf

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
  records             = ["2603:1030:408:7::44"] # publick8s_public_ipv6_address defined in https://github.com/jenkins-infra/azure/blob/main/publick8s.tf

  tags = merge(local.default_tags, {
    purpose = "Jenkinsistheway.io redirector to stories.jenkins.io"
  })
}

### CNAME records
# CNAME records targeting the public-nginx on publick8s cluster
resource "azurerm_dns_cname_record" "jenkinsio_target_public_publick8s" {
  # Map of records and corresponding purposes
  for_each = {
    "accounts"      = "accountapp for Jenkins users"
    "incrementals"  = "incrementals publisher to incrementals Maven repository"
    "javadoc"       = "Jenkins Javadoc"
    "plugin-health" = "Plugin Health Scoring application"
    "rating"        = "Jenkins releases rating service"
    "repo.azure"    = "artifact-caching-proxy on Azure"
    "reports"       = "Public reports about Jenkins services and components consumed by RPU, plugins website and others"
    "uplink"        = "Jenkins telemetry service"
    "weekly.ci"     = "Jenkins Weekly demo controller"
    "wiki"          = "Static Wiki Confluence export"
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60
  record              = "public.publick8s.jenkins.io" # A record defined in https://github.com/jenkins-infra/azure/blob/main/publick8s.tf

  tags = merge(local.default_tags, {
    purpose = each.value
  })
}
# CNAME records for the legacy domain jenkins-ci.org, pointing to their modern counterpart
resource "azurerm_dns_cname_record" "jenkinsciorg_target_public_publick8s" {
  # Map of records and corresponding purposes. Some records only exists in jenkins.io as jenkins-ci.org is only legacy
  for_each = {
    "accounts" = "accountapp for Jenkins users"
    "javadoc"  = "Jenkins Javadoc"
    "wiki"     = "Static Wiki Confluence export"
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsciorg.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsci.name
  ttl                 = 60
  record              = "${each.key}.jenkins.io"

  tags = merge(local.default_tags, {
    purpose = each.value
  })
}

# CNAME records targeting the private-nginx on publick8s cluster
resource "azurerm_dns_cname_record" "jenkinsio_target_private_publick8s" {
  # Map of records and corresponding purposes
  for_each = {
    "admin.accounts" = "Keycloak admin for Jenkins users"
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60
  record              = "private.publick8s.jenkins.io" # A record defined in https://github.com/jenkins-infra/azure/blob/main/publick8s.tf

  tags = merge(local.default_tags, {
    purpose = each.value
  })
}

# CNAME records targeting the public-nginx on privatek8s cluster
resource "azurerm_dns_cname_record" "jenkinsio_target_public_privatek8s" {
  # Map of records and corresponding purposes
  for_each = {
    "webhook-github-comment-ops" = "github-comment-ops GitHub App"
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  record              = "public.privatek8s.jenkins.io" # A record defined on https://github.com/jenkins-infra/azure/blob/main/privatek8s.tf

  tags = merge(local.default_tags, {
    purpose = each.value
  })
}

# CNAME records targeting the private-nginx on privatek8s cluster
resource "azurerm_dns_cname_record" "jenkinsio_target_private_privatek8s" {
  # Map of records and corresponding purposes
  for_each = {
    "release.ci" = "release.ci.jenkins.io, accessible only via the private VPN"
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  record              = "private.privatek8s.jenkins.io" # A record managed manually

  tags = merge(local.default_tags, {
    purpose = each.value
  })
}

# CNAME records targeting the public-nginx on prodpublick8s cluster
# TODO: to be removed after https://github.com/jenkins-infra/helpdesk/issues/3351
resource "azurerm_dns_cname_record" "jenkinsio_target_public_prodpublick8s" {
  # Map of records and corresponding purposes
  for_each = {
    "fallback.get"       = "Fallback address for mirrorbits" # Note: had a TTL of 10 minutes before, not 1 hour
    "get"                = "Jenkins binary distribution via mirrorbits"
    "mirrors"            = "Jenkins binary distribution via mirrorbits"
    "plugin-site-issues" = "Plugins website API content origin for Fastly CDN"
    "plugins.origin"     = "Plugins website content origin for Fastly CDN"
    "www.origin"         = "Jenkins website content origin for Fastly CDN"
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
