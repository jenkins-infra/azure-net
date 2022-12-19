locals {
  default_tags = {
    scope      = "terraform-managed"
    repository = "jenkins-infra/azure-net"
  }

  vpn = {
    shorthostname = "private.vpn"
    username      = "jenkins-infra-team"
    ssh_allowed_inbound_ips = {
      dduportal   = "86.194.33.212/32"
      lemeurherve = "176.185.227.180/32"
      smerle33    = "82.64.5.129/32"
    }
    puppet_outbound_ips = {
      # dig puppet.jenkins.io
      puppet_jenkins_io = "140.211.9.94"
    }
  }
}
