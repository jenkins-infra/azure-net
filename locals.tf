locals {
  default_tags = {
    scope      = "terraform-managed"
    repository = "jenkins-infra/azure-net"
  }

  vpn = {
    shorthostname = "vpn-test"
    username      = "jenkins-infra-team"
    allowed_ips = {
      dduportal   = "109.88.253.68/32"
      lemeurherve = "176.185.227.180/32"
      smerle33    = "82.64.5.129/32"
      olblak      = "109.128.249.199/32"
      olblak_bis  = "86.130.79.46/32"
    }
    puppet_ips = {
      # dig puppet.jenkins.io
      radish_jenkins_io = "140.211.9.94"
    }
  }
}
