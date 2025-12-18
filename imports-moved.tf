import {
  to = azurerm_dns_cname_record.jenkinsio_customs["pkg.origin"]
  id = "/subscriptions/dff2ec18-6a8e-405c-8e45-b7df7465acf0/resourceGroups/proddns_jenkinsio/providers/Microsoft.Network/dnsZones/jenkins.io/CNAME/pkg.origin"
}

import {
  to = azurerm_dns_cname_record.jenkinsio_customs["pkg"]
  id = "/subscriptions/dff2ec18-6a8e-405c-8e45-b7df7465acf0/resourceGroups/proddns_jenkinsio/providers/Microsoft.Network/dnsZones/jenkins.io/CNAME/pkg"
}

import {
  to = azurerm_dns_cname_record.jenkinsciorg_customs["pkg"]
  id = "/subscriptions/dff2ec18-6a8e-405c-8e45-b7df7465acf0/resourceGroups/proddns_jenkinsci/providers/Microsoft.Network/dnsZones/jenkins-ci.org/CNAME/pkg"
}

moved {
  from = azurerm_dns_cname_record.repo_jenkinsci_org
  to   = azurerm_dns_cname_record.jenkinsciorg_customs["repo"]
}
