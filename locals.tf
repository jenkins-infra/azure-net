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

  public_ips = {
    "publick8s_public_ipv4_address" = "20.7.178.24"          # defined in https://github.com/jenkins-infra/azure/blob/main/publick8s.tf
    "publick8s_public_ipv6_address" = "2603:1030:408:5::15a" # defined in https://github.com/jenkins-infra/azure/blob/main/publick8s.tf
    "ldap_jenkins_io_ipv4_address"  = "20.7.180.148"         # defined in https://github.com/jenkins-infra/azure/blob/main/publick8s.tf
  }

  # Tracked by updatecli, easier to use a string split as a list by Terraform
  # NS records pointing to AWS Route53 name servers to delegate aws.ci.jenkins.io to them
  aws_route53_nameservers_awscijenkinsio = "ns-1399.awsdns-46.org ns-1646.awsdns-13.co.uk ns-193.awsdns-24.com ns-609.awsdns-12.net"
}
