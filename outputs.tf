######################################################## Gateways Outbound IPs
output "cert_ci_outbound_ips" {
  value = module.cert_ci_jenkins_io_outbound.public_ip_list
}
output "cert_ci_sponsorship_outbound_ip_list" {
  value = module.cert_ci_jenkins_io_outbound_sponsorship.public_ip_list
}
output "trusted_ci_outbound_ip_list" {
  value = module.trusted_outbound.public_ip_list
}
output "trusted_ci_sponsorship_outbound_ip_list" {
  value = module.trusted_outbound_sponsorship.public_ip_list
}
output "ci_outbound_ip_list" {
  value = module.ci_jenkins_io_outbound.public_ip_list
}
output "ci_sponsorship_outbound_ip_list" {
  value = module.ci_jenkins_io_outbound_sponsorship.public_ip_list
}
output "infra_ci_outbound_ip_list" {
  value = module.infra_ci_outbound_sponsorship.public_ip_list
}
output "publick8s_outbound_ip_list" {
  value = module.publick8s_outbound.public_ip_list
}
output "privatek8s_outbound_ip_list" {
  value = module.privatek8s_outbound.public_ip_list
}
##############################################################################
