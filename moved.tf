## public
moved {
  from = module.publick8s_outbound.azurerm_nat_gateway.outbound
  to   = module.public_vnet.azurerm_nat_gateway.outbound[0]
}
moved {
  from = module.publick8s_outbound.azurerm_public_ip.outbound
  to   = module.public_vnet.azurerm_public_ip.outbound[0]
}
moved {
  from = module.publick8s_outbound.azurerm_subnet_nat_gateway_association.outbound[0]
  to   = module.public_vnet.azurerm_subnet_nat_gateway_association.outbound["publick8s-tier"]
}
moved {
  from = module.publick8s_outbound.azurerm_nat_gateway_public_ip_association.outbound
  to   = module.public_vnet.azurerm_nat_gateway_public_ip_association.outbound[0]
}

## private_sponsorship_vnet
moved {
  from = module.privatek8s_outbound_sponsorship.azurerm_nat_gateway.outbound
  to   = module.private_sponsorship_vnet.azurerm_nat_gateway.outbound[0]
}
moved {
  from = module.privatek8s_outbound_sponsorship.azurerm_public_ip.outbound
  to   = module.private_sponsorship_vnet.azurerm_public_ip.outbound[0]
}
moved {
  from = module.privatek8s_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[0]
  to   = module.private_sponsorship_vnet.azurerm_subnet_nat_gateway_association.outbound["privatek8s-sponsorship-tier"]
}
moved {
  from = module.privatek8s_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[1]
  to   = module.private_sponsorship_vnet.azurerm_subnet_nat_gateway_association.outbound["privatek8s-sponsorship-release-tier"]
}
moved {
  from = module.privatek8s_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[2]
  to   = module.private_sponsorship_vnet.azurerm_subnet_nat_gateway_association.outbound["privatek8s-sponsorship-infraci-ctrl-tier"]
}
moved {
  from = module.privatek8s_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[3]
  to   = module.private_sponsorship_vnet.azurerm_subnet_nat_gateway_association.outbound["privatek8s-sponsorship-releaseci-ctrl-tier"]
}
moved {
  from = module.privatek8s_outbound_sponsorship.azurerm_nat_gateway_public_ip_association.outbound
  to   = module.private_sponsorship_vnet.azurerm_nat_gateway_public_ip_association.outbound[0]
}
moved {
  from = module.privatek8s_outbound_sponsorship.azurerm_public_ip.additional_outbounds[0]
  to   = module.private_sponsorship_vnet.azurerm_public_ip.additional_outbounds[0]
}
moved {
  from = module.privatek8s_outbound_sponsorship.azurerm_nat_gateway_public_ip_association.additional_outbounds[0]
  to   = module.private_sponsorship_vnet.azurerm_nat_gateway_public_ip_association.additional_outbounds[0]
}

## infra-jenkins-io-sponsorship
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_nat_gateway.outbound
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_nat_gateway.outbound[0]
}
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_public_ip.outbound
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_public_ip.outbound[0]
}
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[0]
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_subnet_nat_gateway_association.outbound["infra-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"]
}
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[1]
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_subnet_nat_gateway_association.outbound["infra-ci-jenkins-io-sponsorship-vnet-packer-builds"]
}
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[2]
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_subnet_nat_gateway_association.outbound["infra-ci-jenkins-io-sponsorship-vnet-kubernetes-agents"]
}
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_nat_gateway_public_ip_association.outbound
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_nat_gateway_public_ip_association.outbound[0]
}
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_public_ip.additional_outbounds[0]
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_public_ip.additional_outbounds[0]
}
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_nat_gateway_public_ip_association.additional_outbounds[0]
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_nat_gateway_public_ip_association.additional_outbounds[0]
}

## ci-jenkins-io-sponsorship
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_nat_gateway.outbound
  to   = module.public_sponsorship_vnet.azurerm_nat_gateway.outbound[0]
}
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_public_ip.outbound
  to   = module.public_sponsorship_vnet.azurerm_public_ip.outbound[0]
}
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[0]
  to   = module.public_sponsorship_vnet.azurerm_subnet_nat_gateway_association.outbound["public-jenkins-sponsorship-vnet-ci_jenkins_io_agents"]
}
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[1]
  to   = module.public_sponsorship_vnet.azurerm_subnet_nat_gateway_association.outbound["public-jenkins-sponsorship-vnet-ci_jenkins_io_controller"]
}
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[2]
  to   = module.public_sponsorship_vnet.azurerm_subnet_nat_gateway_association.outbound["public-jenkins-sponsorship-vnet-ci_jenkins_io_kubernetes"]
}
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_nat_gateway_public_ip_association.outbound
  to   = module.public_sponsorship_vnet.azurerm_nat_gateway_public_ip_association.outbound[0]
}
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_public_ip.additional_outbounds[0]
  to   = module.public_sponsorship_vnet.azurerm_public_ip.additional_outbounds[0]
}
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_nat_gateway_public_ip_association.additional_outbounds[0]
  to   = module.public_sponsorship_vnet.azurerm_nat_gateway_public_ip_association.additional_outbounds[0]
}

## cert-ci-jenkins-io-sponsorship
moved {
  from = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_nat_gateway.outbound
  to   = module.cert_ci_jenkins_io_sponsorship_vnet.azurerm_nat_gateway.outbound[0]
}
moved {
  from = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_public_ip.outbound
  to   = module.cert_ci_jenkins_io_sponsorship_vnet.azurerm_public_ip.outbound[0]
}
moved {
  from = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[0]
  to   = module.cert_ci_jenkins_io_sponsorship_vnet.azurerm_subnet_nat_gateway_association.outbound["cert-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"]
}
moved {
  from = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_nat_gateway_public_ip_association.outbound
  to   = module.cert_ci_jenkins_io_sponsorship_vnet.azurerm_nat_gateway_public_ip_association.outbound[0]
}
moved {
  from = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_public_ip.additional_outbounds[0]
  to   = module.cert_ci_jenkins_io_sponsorship_vnet.azurerm_public_ip.additional_outbounds[0]
}
moved {
  from = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_nat_gateway_public_ip_association.additional_outbounds[0]
  to   = module.cert_ci_jenkins_io_sponsorship_vnet.azurerm_nat_gateway_public_ip_association.additional_outbounds[0]
}

## cert-ci-jenkins-io
moved {
  from = module.cert_ci_jenkins_io_outbound.azurerm_nat_gateway.outbound
  to   = module.cert_ci_jenkins_io_vnet.azurerm_nat_gateway.outbound[0]
}
moved {
  from = module.cert_ci_jenkins_io_outbound.azurerm_public_ip.outbound
  to   = module.cert_ci_jenkins_io_vnet.azurerm_public_ip.outbound[0]
}
moved {
  from = module.cert_ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound[0]
  to   = module.cert_ci_jenkins_io_vnet.azurerm_subnet_nat_gateway_association.outbound["cert-ci-jenkins-io-vnet-controller"]
}
moved {
  from = module.cert_ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound[1]
  to   = module.cert_ci_jenkins_io_vnet.azurerm_subnet_nat_gateway_association.outbound["cert-ci-jenkins-io-vnet-ephemeral-agents"]
}
moved {
  from = module.cert_ci_jenkins_io_outbound.azurerm_nat_gateway_public_ip_association.outbound
  to   = module.cert_ci_jenkins_io_vnet.azurerm_nat_gateway_public_ip_association.outbound[0]
}

## trusted-ci-jenkins-io
moved {
  from = module.trusted_outbound.azurerm_nat_gateway.outbound
  to   = module.trusted_ci_jenkins_io_vnet.azurerm_nat_gateway.outbound[0]
}
moved {
  from = module.trusted_outbound.azurerm_public_ip.outbound
  to   = module.trusted_ci_jenkins_io_vnet.azurerm_public_ip.outbound[0]
}
moved {
  from = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound[0]
  to   = module.trusted_ci_jenkins_io_vnet.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-vnet-controller"]
}
moved {
  from = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound[1]
  to   = module.trusted_ci_jenkins_io_vnet.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-vnet-permanent-agents"]
}
moved {
  from = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound[2]
  to   = module.trusted_ci_jenkins_io_vnet.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-vnet-ephemeral-agents"]
}
moved {
  from = module.trusted_outbound.azurerm_nat_gateway_public_ip_association.outbound
  to   = module.trusted_ci_jenkins_io_vnet.azurerm_nat_gateway_public_ip_association.outbound[0]
}


## trusted-ci-jenkins-io-sponsorship
moved {
  from = module.trusted_outbound_sponsorship.azurerm_nat_gateway.outbound
  to   = module.trusted_ci_jenkins_io_sponsorship_vnet.azurerm_nat_gateway.outbound[0]
}
moved {
  from = module.trusted_outbound_sponsorship.azurerm_public_ip.outbound
  to   = module.trusted_ci_jenkins_io_sponsorship_vnet.azurerm_public_ip.outbound[0]
}
moved {
  from = module.trusted_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[0]
  to   = module.trusted_ci_jenkins_io_sponsorship_vnet.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"]
}
moved {
  from = module.trusted_outbound_sponsorship.azurerm_nat_gateway_public_ip_association.outbound
  to   = module.trusted_ci_jenkins_io_sponsorship_vnet.azurerm_nat_gateway_public_ip_association.outbound[0]
}
moved {
  from = module.trusted_outbound_sponsorship.azurerm_public_ip.additional_outbounds[0]
  to   = module.trusted_ci_jenkins_io_sponsorship_vnet.azurerm_public_ip.additional_outbounds[0]
}
moved {
  from = module.trusted_outbound_sponsorship.azurerm_nat_gateway_public_ip_association.additional_outbounds[0]
  to   = module.trusted_ci_jenkins_io_sponsorship_vnet.azurerm_nat_gateway_public_ip_association.additional_outbounds[0]
}
moved {
  from = module.trusted_outbound_sponsorship.azurerm_public_ip.additional_outbounds[1]
  to   = module.trusted_ci_jenkins_io_sponsorship_vnet.azurerm_public_ip.additional_outbounds[1]
}
moved {
  from = module.trusted_outbound_sponsorship.azurerm_nat_gateway_public_ip_association.additional_outbounds[1]
  to   = module.trusted_ci_jenkins_io_sponsorship_vnet.azurerm_nat_gateway_public_ip_association.additional_outbounds[1]
}
