locals {
  default_tags = {
    scope      = "terraform-managed"
    repository = "jenkins-infra/azure-net"
  }

  vpn_shorthostname = "vpn-test"
  vpn_username      = "jenkins-infra-team"
}
