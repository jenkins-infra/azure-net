resource "local_file" "jenkins_infra_data_report" {
  content = jsonencode({
    "cert.ci.jenkins.io" = {
      "outbound_ips" = concat(
        # Controller
        split(",", module.cert_ci_jenkins_io_vnet.public_ip_list),
        # Agents
        split(",", module.cert_ci_jenkins_io_sponsorship_vnet.public_ip_list)
      ),
    },
    "trusted.ci.jenkins.io" = {
      "outbound_ips" = split(",", module.trusted_ci_jenkins_io_vnet.public_ip_list),
    },
    "infra.ci.jenkins.io" = {
      "outbound_ips" = concat(
        # Controller
        split(",", module.private_vnet.public_ip_list),
        # Agents
        split(",", module.infra_ci_jenkins_io_vnet.public_ip_list),
      ),
    },
    "privatek8s.jenkins.io" = {
      "outbound_ips"      = split(",", module.private_vnet.public_ip_list),
      "private_lb_subnet" = "privatek8s-tier",
    },
    "private.vpn.jenkins.io" = {
      # VPN VM uses its public IP as outbound method (default Azure behavior) instead of the outbound NAT gateway
      "outbound_ips" = [azurerm_public_ip.vpn_public.ip_address],
    },
    "vnets" = {
      "cert-ci-jenkins-io-sponsorship-vnet" = module.cert_ci_jenkins_io_sponsorship_vnet.vnet_address_space,
      "cert-ci-jenkins-io-vnet"             = module.cert_ci_jenkins_io_vnet.vnet_address_space,
      "infra-ci-jenkins-io-vnet"            = module.infra_ci_jenkins_io_vnet.vnet_address_space,
      "private-vnet"                        = module.private_vnet.vnet_address_space,
      "public-db-vnet"                      = module.public_db_vnet.vnet_address_space,
      "public-vnet"                         = module.public_vnet.vnet_address_space,
      "trusted-ci-jenkins-io-vnet"          = module.trusted_ci_jenkins_io_vnet.vnet_address_space,
    }
  })
  filename = "${path.module}/jenkins-infra-data-reports/azure-net.json"
}
output "jenkins_infra_data_report" {
  value = local_file.jenkins_infra_data_report.content
}
