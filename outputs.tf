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
      "outbound_ips" = split(",", module.publick8s_outbound.public_ip_list),
    },
    "publick8s.jenkins.io" = {
      "outbound_ips" = split(",", module.publick8s_outbound.public_ip_list),
    },
  })
  filename = "${path.module}/jenkins-infra-data-reports/azure-net.json"
}
