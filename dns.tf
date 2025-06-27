# TODO: import as resource
data "azurerm_resource_group" "proddns_jenkinsio" {
  name = "proddns_jenkinsio"
}

# TODO: import as resource
data "azurerm_resource_group" "proddns_jenkinsci" {
  name = "proddns_jenkinsci"
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
