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
        ips = [
          "85.26.116.129/32", # Home
        ],
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
      puppet_jenkins_io = "20.12.27.65"
    }
  }

  lets_encrypt_dns_challenged_domains = {
    "trusted.ci.jenkins.io" = "2024-04-03T20:00:00Z"
    "cert.ci.jenkins.io"    = "2024-04-03T21:00:00Z"
    # TODO: add support for workload identities by providing an empty expiration date
    # "<something>.jenkins.io" = ""
  }

  public_ips = {
    "publick8s-inbound" = "20.119.232.75"
  }
}
