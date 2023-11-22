### A and AAAA records
## jenkins.io DNS zone records

# Apex ("@") records for the jenkins.io zone
resource "azurerm_dns_a_record" "jenkins_io" {
  name                = "@"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60
  records             = [local.public_ips["publick8s_public_ipv4_address"]]

  tags = merge(local.default_tags, {
    purpose = "Jenkins website"
  })
}
resource "azurerm_dns_aaaa_record" "jenkins_io" {
  name                = "@"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60
  records             = [local.public_ips["publick8s_public_ipv6_address"]]

  tags = merge(local.default_tags, {
    purpose = "Jenkins website"
  })
}

# Apex ("@") records for the jenkins-ci.org zone
resource "azurerm_dns_a_record" "jenkinsciorg" {
  name                = "@"
  zone_name           = data.azurerm_dns_zone.jenkinsciorg.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsci.name
  ttl                 = 60
  records             = [local.public_ips["publick8s_public_ipv4_address"]]

  tags = merge(local.default_tags, {
    purpose = "Jenkins website"
  })
}
resource "azurerm_dns_aaaa_record" "jenkinsciorg" {
  name                = "@"
  zone_name           = data.azurerm_dns_zone.jenkinsciorg.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsci.name
  ttl                 = 60
  records             = [local.public_ips["publick8s_public_ipv6_address"]]

  tags = merge(local.default_tags, {
    purpose = "Jenkins website"
  })
}

# CAA records to restrict Certificate Authorities
resource "azurerm_dns_caa_record" "jenkins_caa" {
  for_each = {
    "${data.azurerm_dns_zone.jenkinsio.name}"    = "${data.azurerm_dns_zone.jenkinsio.resource_group_name}",
    "${data.azurerm_dns_zone.jenkinsciorg.name}" = "${data.azurerm_dns_zone.jenkinsciorg.resource_group_name}",
  }
  name                = "@"
  zone_name           = each.key
  resource_group_name = each.value
  ttl                 = 60

  record {
    flags = 0
    tag   = "issue"
    value = "letsencrypt.org"
  }

  record {
    flags = 0
    tag   = "issue"
    value = "godaddy.com"
  }

  record {
    flags = 0
    tag   = "issue"
    value = "amazon.com"
  }

  record {
    flags = 0
    tag   = "issue"
    value = "globalsign.com"
  }

  record {
    flags = 0
    tag   = "issue"
    value = "digicert.com; cansignhttpexchanges=yes"
  }

  record {
    flags = 0
    tag   = "issue"
    value = "sectigo.com"
  }

  record {
    flags = 0
    tag   = "issue"
    value = "pki.goog; cansignhttpexchanges=yes"
  }

  tags = merge(local.default_tags, {
    purpose = "Jenkins user authentication service"
  })
}

# A record for ldap.jenkins.io pointing to its own public LB IP from publick8s cluster
resource "azurerm_dns_a_record" "ldap_jenkins_io" {
  name                = "ldap"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60
  records             = [local.public_ips["ldap_jenkins_io_ipv4_address"]]

  tags = merge(local.default_tags, {
    purpose = "Jenkins user authentication service"
  })
}

# A record pointing to doks-public cluster public IPv4 address
# Note: no IPv6 record as DO LB do not support them (mid-2023): https://docs.digitalocean.com/products/networking/load-balancers/details/limits/
resource "azurerm_dns_a_record" "doks_public_public_ipv4_address" {
  name                = "doks-public-public-ipv4-address"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60
  records             = [local.public_ips["doks_public_public_ipv4_address"]]

  tags = merge(local.default_tags, {
    purpose = "Public IPv4 address of doks-public cluster for common reference"
  })
}

## jenkinsistheway.io DNS zone records
# Apex records for the jenkinsistheway.io redirector hosted on publick8s redirecting to stories.jenkins.io
resource "azurerm_dns_a_record" "jenkinsistheway_io" {
  name                = "@"
  zone_name           = azurerm_dns_zone.jenkinsistheway_io.name
  resource_group_name = azurerm_resource_group.proddns_jenkinsisthewayio.name
  ttl                 = 60
  records             = [local.public_ips["publick8s_public_ipv4_address"]]

  tags = merge(local.default_tags, {
    purpose = "Jenkinsistheway.io redirector to stories.jenkins.io"
  })
}
resource "azurerm_dns_aaaa_record" "jenkinsistheway_io_ipv6" {
  name                = "@"
  zone_name           = azurerm_dns_zone.jenkinsistheway_io.name
  resource_group_name = azurerm_resource_group.proddns_jenkinsisthewayio.name
  ttl                 = 60
  records             = [local.public_ips["publick8s_public_ipv6_address"]]

  tags = merge(local.default_tags, {
    purpose = "Jenkinsistheway.io redirector to stories.jenkins.io"
  })
}

### CNAME records
# CNAME records targeting the public-nginx on publick8s cluster
resource "azurerm_dns_cname_record" "jenkinsio_target_public_publick8s" {
  # Map of records and corresponding purposes
  for_each = {
    "accounts"            = "accountapp for Jenkins users"
    "contributors.origin" = "Jenkins Contributors Spotlight website content origin for Fastly CDN"
    "fallback.get"        = "Fallback address for mirrorbits" # Note: had a TTL of 10 minutes before, not 1 hour
    "get"                 = "Jenkins binary distribution via mirrorbits"
    "incrementals"        = "incrementals publisher to incrementals Maven repository"
    "javadoc"             = "Jenkins Javadoc"
    "mirrors"             = "Jenkins binary distribution via mirrorbits"
    "plugin-health"       = "Plugin Health Scoring application"
    "plugin-site-issues"  = "Plugins website API content origin for Fastly CDN"
    "plugins.origin"      = "Plugins website content origin for Fastly CDN"
    "rating"              = "Jenkins releases rating service"
    "repo.azure"          = "artifact-caching-proxy on Azure"
    "reports"             = "Public reports about Jenkins services and components consumed by RPU, plugins website and others"
    "uplink"              = "Jenkins telemetry service"
    "weekly.ci"           = "Jenkins Weekly demo controller"
    "wiki"                = "Static Wiki Confluence export"
    "www.origin"          = "Jenkins website content origin for Fastly CDN"
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
    "mirrors"  = "Jenkins binary distribution via mirrorbits"
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

# CNAME records used for Fastly ACME validations
resource "azurerm_dns_cname_record" "jenkinsio_acme_fastly" {
  # Map of records and corresponding purposes
  for_each = {
    "_acme-challenge.pkg"     = "f44lzqsppt1dj85jf3.fastly-validations.com",
    "_acme-challenge.plugins" = "tr8qxfomlsxfq1grha.fastly-validations.com",
    "_acme-challenge.stories" = "k31jn864ll8jjqhmik.fastly-validations.com",
    "_acme-challenge.www"     = "1vt5byhannlhjvm56n.fastly-validations.com",
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  record              = each.value

  tags = merge(local.default_tags, {
    purpose = "ACME validation for Fastly (${each.key})"
  })
}

# CNAME records used for Fastly to serve some of our websites through their CDN
resource "azurerm_dns_cname_record" "jenkinsio_fastly" {
  # Map of records and corresponding purposes
  for_each = {
    "contributors" = "Jenkins Contributors Spotlight website",
    "pkg"          = "Website to download Jenkins packages",
    "plugins"      = "Website to browse and download Jenkins plugins",
    "stories"      = "Website with Jenkins User stories and testimonies",
    "way.the.is"   = "Old alias for stories.jenkins.io",
    "www"          = "Jenkins official website",
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  record              = "dualstack.d.sni.global.fastly.net"

  tags = merge(local.default_tags, {
    purpose = each.value
  })
}

# Custom CNAME records
resource "azurerm_dns_cname_record" "jenkinsio_customs" {
  # Map of records and corresponding purposes
  for_each = {
    "stats" = {
      "target"      = "jenkins-infra.github.io"
      "description" = "Website to download Jenkins packages",
    },
    "charts" = {
      "target"      = "jenkinsci.github.io"
      "description" = "Jenkins Helm Chart repository",
    },
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  record              = each.value["target"]

  tags = merge(local.default_tags, {
    purpose = each.value["description"]
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
