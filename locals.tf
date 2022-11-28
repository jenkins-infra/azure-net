locals {
  default_tags = {
    scope      = "terraform-managed"
    repository = "jenkins-infra/azure-net"
  }

  vpn_subdomain = "vpn-test"
}
