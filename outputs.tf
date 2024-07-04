resource "local_file" "jenkins_infra_data_report" {
  content = jsonencode({
    "cert.ci.jenkins.io" = {
      "outbound_ips" = concat(split(",", module.cert_ci_jenkins_io_outbound.public_ip_list), split(",", module.cert_ci_jenkins_io_outbound_sponsorship.public_ip_list)),
    },
    "trusted.ci.jenkins.io" = {
      "outbound_ips" = concat(split(",", module.trusted_outbound.public_ip_list), split(",", module.trusted_outbound_sponsorship.public_ip_list)),
    },
    "ci.jenkins.io" = {
      "outbound_ips" = concat(split(",", module.ci_jenkins_io_outbound.public_ip_list), split(",", module.ci_jenkins_io_outbound_sponsorship.public_ip_list)),
    },
    "infra.ci.jenkins.io" = {
      "outbound_ips" = concat(split(",", module.infra_ci_outbound_sponsorship.public_ip_list), split(",", module.privatek8s_outbound.public_ip_list)),
    },
    "privatek8s.jenkins.io" = {
      "outbound_ips" = split(",", module.privatek8s_outbound.public_ip_list),
    },
    "publick8s.jenkins.io" = {
      "outbound_ips" = split(",", module.publick8s_outbound.public_ip_list),
    },
    "cijenkinsioagents1.jenkins.io" = {
      "outbound_ips" = split(",", module.ci_jenkins_io_outbound_sponsorship.public_ip_list),
    }
    "infracijenkinsioagents1.jenkins.io" = {
      "outbound_ips" = split(",", module.infra_ci_outbound_sponsorship.public_ip_list),
    }
    "vnets" = {
      "cert-ci-jenkins-io-sponsorship-vnet"    = module.cert_ci_jenkins_io_sponsorship_vnet.vnet_address_space,
      "cert-ci-jenkins-io-vnet"                = module.cert_ci_jenkins_io_vnet.vnet_address_space,
      "infra-ci-jenkins-io-sponsorship-vnet"   = module.infra_ci_jenkins_io_sponsorship_vnet.vnet_address_space,
      "private-vnet"                           = module.private_vnet.vnet_address_space,
      "public-db-vnet"                         = module.public_db_vnet.vnet_address_space,
      "public-jenkins-sponsorship-vnet"        = module.public_sponsorship_vnet.vnet_address_space,
      "public-vnet"                            = module.public_vnet.vnet_address_space,
      "trusted-ci-jenkins-io-sponsorship-vnet" = module.trusted_ci_jenkins_io_sponsorship_vnet.vnet_address_space,
      "trusted-ci-jenkins-io-vnet"             = module.trusted_ci_jenkins_io_vnet.vnet_address_space,
    }
  })
  filename = "${path.module}/jenkins-infra-data-reports/azure-net.json"
}
