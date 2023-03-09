locals {
  default_tags = {
    scope      = "terraform-managed"
    repository = "jenkins-infra/azure-net"
  }

  vpn = {
    shorthostname = "private.vpn"
    username      = "jenkins-infra-team"
    ssh_allowed_inbound_ips = {
      dduportal = {
        ips      = ["85.27.58.68/32", ]
        priority = 101,
      },
      lemeurherve = {
        ips      = ["176.185.227.180/32"],
        priority = 102,
      }
      smerle33 = {
        ips      = ["82.64.5.129/32"],
        priority = 103,
      }
      mwaite = {
        ips      = ["162.142.59.220/32"]
        priority = 104,
      }
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
