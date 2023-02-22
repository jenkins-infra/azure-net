locals {
  default_tags = {
    scope      = "terraform-managed"
    repository = "jenkins-infra/azure-net"
  }

  vpn = {
    shorthostname = "private.vpn"
    username      = "jenkins-infra-team"
    ssh_allowed_inbound_ips = {
      dduportal   = "85.27.58.68/32"
      dduportal2  = "149.154.214.236/32"
      lemeurherve = "176.185.227.180/32"
      smerle33    = "82.64.5.129/32"
      mwaite      = "162.142.59.220/32"
    }
    puppet_outbound_ips = {
      # dig puppet.jenkins.io
      puppet_jenkins_io = "140.211.9.94"
    }
  }

  lets_encrypt_dns_challenged_domains = {
    "trusted.ci.jenkins.io" = "service_principal"
    ## TODO: add support for workload identities:
    # "cert.ci.jenkins.io" = "managed_identity"
  }
}
