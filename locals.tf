locals {
  default_tags = {
    scope      = "terraform-managed"
    repository = "jenkins-infra/azure-net"
  }

  vpn = {
    shorthostname = "private.vpn"
    username      = "jenkins-infra-team"
    puppet_outbound_ips = {
      # dig puppet.jenkins.io
      puppet_jenkins_io = "20.12.27.65"
    }
  }

  lets_encrypt_dns_challenged_domains = {
    "trusted.ci.jenkins.io" = "2024-04-03T20:00:00Z"
    "cert.ci.jenkins.io"    = "2024-07-04T00:00:00Z"
    # TODO: add support for workload identities by providing an empty expiration date
    # "<something>.jenkins.io" = ""
  }

  public_ips = {
    "publick8s_public_ipv4_address"   = "20.7.178.24"          # defined in https://github.com/jenkins-infra/azure/blob/main/publick8s.tf
    "publick8s_public_ipv6_address"   = "2603:1030:408:5::15a" # defined in https://github.com/jenkins-infra/azure/blob/main/publick8s.tf
    "ldap_jenkins_io_ipv4_address"    = "20.7.180.148"         # defined in https://github.com/jenkins-infra/azure/blob/main/publick8s.tf
    "doks_public_public_ipv4_address" = "157.245.23.55"        # defined in https://github.com/jenkins-infra/digitalocean/blob/main/doks-public-cluster.tf
  }
}
