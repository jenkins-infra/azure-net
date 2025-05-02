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

# Cleanup once the resources are managed in jenkins-infra/azure - https://github.com/jenkins-infra/helpdesk/issues/4630#issuecomment-2846886448
removed {
  from = azurerm_dns_zone.child_zones

  lifecycle {
    destroy = false
  }
}
# Cleanup once the resources are managed in jenkins-infra/azure - https://github.com/jenkins-infra/helpdesk/issues/4630#issuecomment-2846886448
removed {
  from = azurerm_dns_ns_record.child_zone_ns_records

  lifecycle {
    destroy = false
  }
}
