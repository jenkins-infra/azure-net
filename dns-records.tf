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

## Records for lists.jenkins-ci.org (hosted at OSUOSL)
# Ref. https://github.com/jenkins-infra/helpdesk/issues/4366
resource "azurerm_dns_a_record" "listsjenkinsciorg" {
  name                = "lists"
  zone_name           = data.azurerm_dns_zone.jenkinsciorg.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsci.name
  ttl                 = 60
  records             = ["140.211.9.53"]

  tags = merge(local.default_tags, {
    purpose = "Legacy Jenkins Lists hosted on OSUOSL"
  })
}
resource "azurerm_dns_aaaa_record" "listsjenkinsciorg" {
  name                = "lists"
  zone_name           = data.azurerm_dns_zone.jenkinsciorg.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsci.name
  ttl                 = 60
  records             = ["2605:bc80:3010:104::8cd3:935"]

  tags = merge(local.default_tags, {
    purpose = "Legacy Jenkins Lists hosted on OSUOSL"
  })
}
resource "azurerm_dns_txt_record" "listsjenkinsciorg" {
  name                = "lists"
  zone_name           = data.azurerm_dns_zone.jenkinsciorg.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsci.name
  ttl                 = 60

  record {
    value = "v=spf1 mx include:_spf.osuosl.org ~all"
  }

  tags = merge(local.default_tags, {
    purpose = "Legacy Jenkins Lists hosted on OSUOSL"
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

### CNAME records
# CNAME records targeting the public-nginx on publick8s cluster
resource "azurerm_dns_cname_record" "jenkinsio_target_public_new_publick8s" {
  # Map of records and corresponding purposes
  for_each = {
    "accounts"            = "accountapp for Jenkins users"
    "alpha.docs"          = "Versioned docs of jenkins.io content"
    "assets.weekly.ci"    = "Resource root URL for public controller weekly.ci.jenkins.io"
    "azure.updates"       = "Update Center hosted on Azure (Apache redirections service)"
    "builds.reports"      = "Public build reports about the private Jenkins controllers of the Jenkins infrastructure"
    "contributors.origin" = "Jenkins Contributors Spotlight website content origin for Fastly CDN"
    "docs.origin"         = "Versioned docs of jenkins.io content origin for Fastly CDN" # TODO: to be replaced by alpha.docs
    "fallback.get"        = "Fallback address for mirrorbits" # Note: had a TTL of 10 minutes before, not 1 hour
    "get"                 = "Jenkins binary distribution via mirrorbits"
    "incrementals"        = "incrementals publisher to incrementals Maven repository"
    "issue-redirect"      = "Redirects JENKINS Jira issues to GitHub if they are migrated else to Jira"
    "javadoc"             = "Jenkins Javadoc"
    "mirrors.updates"     = "Update Center hosted on Azure (Mirrorbits redirections service)"
    "mirrors"             = "Jenkins binary distribution via mirrorbits"
    "pkg.origin"          = "Jenkins Package Downloads service"
    "plugin-health"       = "Plugin Health Scoring application"
    "plugin-site-issues"  = "Plugins website API content origin for Fastly CDN"
    "plugins.origin"      = "Plugins website content origin for Fastly CDN"
    "rating"              = "Jenkins releases rating service"
    "reports"             = "Public reports about Jenkins services and components consumed by RPU, plugins website and others"
    "stats"               = "New Jenkins Statistics website"
    "uplink"              = "Jenkins telemetry service"
    "weekly.ci"           = "Jenkins Weekly demo controller"
    "wiki"                = "Static Wiki Confluence export"
    "www.origin"          = "Jenkins website content origin for Fastly CDN"
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60
  record              = "public.publick8s.jenkins.io" # A record defined in https://github.com/jenkins-infra/azure/blob/main/old_publick8s.tf

  tags = merge(local.default_tags, {
    purpose = each.value
  })
}

# CNAME records for the legacy domain jenkins-ci.org, pointing to their modern (e.g. *.jenkins.io) counterpart
resource "azurerm_dns_cname_record" "jenkinsciorg_target_jenkinsio" {
  # Map of records and corresponding purposes. Some records only exists in jenkins.io as jenkins-ci.org is only legacy
  for_each = {
    "accounts" = "accountapp for Jenkins users"
    "archives" = "archives.jenkins.io stores all the Jenkins binaries (installers, plugins, etc.) and acts a s fallback for the download (and update center) mirror systems.",
    "javadoc"  = "Jenkins Javadoc"
    "mirrors"  = "Jenkins binary distribution via mirrorbits"
    "updates"  = "Jenkins Update Center"
    "usage"    = "Usage telemetry for jenkins controllers"
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
    "admin.accounts"     = "Keycloak admin for Jenkins users"
    "staging.get"        = "Staging of get.jenkins.io"
    "staging.pkg.origin" = "Staging of pkg.origin.jenkins.io"
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

# CNAME records targeting the public-nginx on privatek8s (CDF) cluster
resource "azurerm_dns_cname_record" "jenkinsio_target_public_privatek8s_cdf" {
  # Map of records and corresponding purposes
  for_each = {
    "infra-webhooks.ci"          = "infra.ci.jenkins.io webhooks from GitHub"
    "webhook-github-comment-ops" = "github-comment-ops GitHub App"
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 300
  record              = "public.privatek8s.jenkins.io" # A record defined in https://github.com/jenkins-infra/azure

  tags = merge(local.default_tags, {
    purpose = each.value
  })
}

# CNAME records targeting the private-nginx on privatek8s cluster
resource "azurerm_dns_cname_record" "jenkinsio_target_private_privatek8s_cdf" {
  # Map of records and corresponding purposes
  for_each = {
    "infra.ci"          = "infra.ci.jenkins.io, only accessible via the private VPN",
    "release.ci"        = "release.ci.jenkins.io, only accessible via the private VPN"
    "assets.infra.ci"   = "Resource root URL for private controller infra.ci.jenkins.io",
    "assets.release.ci" = "Resource root URL for private controller release.ci.jenkins.io"
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
    "docs"         = "Versioned docs of jenkins.io",
    "pkg"          = "Jenkins Package Downloads with Fastly as CDN",
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
    "old.stats" = {
      "target"      = "jenkins-infra.github.io",
      "description" = "Website to download Jenkins packages",
    },
    "charts" = {
      "target"      = "jenkinsci.github.io",
      "description" = "Jenkins Helm Chart repository",
    },
    "ci" = {
      "target"      = "aws.ci.jenkins.io",
      "description" = "Public controller ci.jenkins.io",
      # TODO: extend once migrated to AWS
      "ttl" = 60,
    },
    "assets.ci" = {
      "target"      = "assets.aws.ci.jenkins.io",
      "description" = "Resource root URL for public controller ci.jenkins.io",
      # TODO: extend once migrated to AWS
      "ttl" = 60,
    },
    "issues" = {
      "target"      = "jenkinsci-jira-alb-368766416.us-west-2.elb.amazonaws.com",
      "description" = "Jenkins public JIRA hosted by the Linux Foundation",
      # TODO: extend once migrated to new LF JIRA
      "ttl" = 60,
    },
    "_b1ff2d9eff9b1643970f47de4281ce22.issues" = {
      "target"      = "_d7eac0ec254ecc89fbb3d23a37f99fbd.zbkrxsrfvj.acm-validations.aws",
      "description" = "TLS challenge for issues.jenbkins.io (managed by LF) - jenkins-infra/helpdesk-4757",
      "ttl"         = 60,
    },
    "updates" = {
      "target"      = "azure.updates.jenkins.io"
      "description" = "Jenkins Update Center"
    },
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = lookup(each.value, "ttl", 300)
  record              = each.value["target"]

  tags = merge(local.default_tags, {
    purpose = each.value["description"]
  })
}
resource "azurerm_dns_cname_record" "jenkinsciorg_customs" {
  # Map of records and corresponding purposes
  for_each = {
    "repo" = {
      "target"      = "jenkinsci.jfrog.org",
      "description" = "Artifactory instance hosted by Jfrog",
      "ttl"         = 60,
    },
    "pkg" = {
      "target"      = "pkg.origin.jenkins.io", # Cannot point to Fastly (would require a Fastly custom website)
      "description" = "Jenkins Package Downloads with Fastly as CDN",
    }
  }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsciorg.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsci.name
  ttl                 = lookup(each.value, "ttl", 300)
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
resource "azurerm_dns_txt_record" "apex_jenkinsio" {
  name                = "@"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60
  record {
    # Used for Libera Chat - https://www.jenkins.io/blog/2021/06/17/libera-chat/
    value = "libera-MjLnxZ2KPqJJnJr6X4WFovAe"
  }
  record {
    # Used for Code Signing Certificate generation - https://github.com/jenkins-infra/helpdesk/issues/3083
    value = "_globalsign-domain-verification=b1pmSjP4FyG8hkZunkD3Aoz8tK0FWCje80-YwtLeDU"
  }
  record {
    # Used to access Google Console Search until https://github.com/jenkins-infra/helpdesk/issues/3530 is done
    value = "google-site-verification=4Z81CA6VzprPWEbGFtNbJwWoZBTGmTp3dk7N0hbt87U"
  }
  record {
    value = "v=spf1 include:mailgun.org include:sendgrid.net include:_spf.google.com ~all"
  }
  record {
    # Used to verify domain ownership. JB checks every 24h.
    value = "jetbrains-domain-verification=9memu05gp112di1q7gijggppf"
  }

  tags = local.default_tags
}
# Used for Maven Central ownership proof
resource "azurerm_dns_txt_record" "lib_jenkins_io" {
  name                = "lib"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60

  record {
    value = "ae2wiz6pk8"
  }

  tags = local.default_tags
}
resource "azurerm_dns_txt_record" "apex_jenkinsciorg" {
  name                = "@"
  zone_name           = data.azurerm_dns_zone.jenkinsciorg.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsci.name
  ttl                 = 60
  record {
    # Sendgrid email setup and SPF
    value = "v=spf1 mx ip4:199.193.196.24 ip4:140.211.15.0/24 ip4:140.211.8.0/23 ip4:173.203.60.151 ip4:140.211.166.128/25 include:sendgrid.net -all"
  }
  record {
    # TODO: identify this value
    value = "d9g3op5gq2093d1q9kqc4mteqr"
  }
  record {
    # TXT record for Godaddy 2023 Dec. certificate renewal - https://groups.google.com/g/jenkins-infra/c/EgbRESb74oA/m/GogykGRFAwAJ
    value = "37vdk1n5ihnd474hlm060uiek6"
  }

  tags = local.default_tags
}

### CAA Records
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
resource "azurerm_dns_ns_record" "aws_ci_jenkins_io" {
  name                = "aws.ci"
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60

  records = split(" ", local.aws_route53_nameservers_awscijenkinsio)

  tags = local.default_tags
}

# CNAMEs of services hosted in DigitalOcean which has its own DNS zone "*.do.jenkins.io" - https://github.com/jenkins-infra/digitalocean/blob/main/dns.tf
resource "azurerm_dns_cname_record" "digitalocean_cnames" {
  for_each = {
    "archives" = "archives.jenkins.io stores all the Jenkins binaries (installers, plugins, etc.) and acts a s fallback for the download (and update center) mirror systems.",
    "usage"    = "usage.jenkins.io used to get telemetry from jenkins controllers",
    "census"   = "census.jenkins.io is a permanent agent machine for trusted.ci.jenkins.io which processes all the Jenkins platform statistics from usage.jenkins.io in a private area."
  }
  name                = each.key
  zone_name           = data.azurerm_dns_zone.jenkinsio.name
  resource_group_name = data.azurerm_resource_group.proddns_jenkinsio.name
  ttl                 = 60
  record              = "${each.key}.do.jenkins.io"
  tags = merge(local.default_tags, {
    purpose = each.value,
  })
}
