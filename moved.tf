## Resource groups
moved {
  from = azurerm_resource_group.public
  to   = module.public_vnet.azurerm_resource_group.vnet_rg[0]
}
moved {
  from = azurerm_resource_group.public_jenkins_sponsorship
  to   = module.public_sponsorship_vnet.azurerm_resource_group.vnet_rg[0]
}
moved {
  from = azurerm_resource_group.private
  to   = module.private_vnet.azurerm_resource_group.vnet_rg[0]
}
moved {
  from = azurerm_resource_group.trusted_ci_jenkins_io
  to   = module.trusted_ci_jenkins_io_vnet.azurerm_resource_group.vnet_rg[0]
}
moved {
  from = azurerm_resource_group.trusted_ci_jenkins_io_sponsorship
  to   = module.trusted_ci_jenkins_io_sponsorship_vnet.azurerm_resource_group.vnet_rg[0]
}
moved {
  from = azurerm_resource_group.cert_ci_jenkins_io
  to   = module.cert_ci_jenkins_io_vnet.azurerm_resource_group.vnet_rg[0]
}
moved {
  from = azurerm_resource_group.cert_ci_jenkins_io_sponsorship
  to   = module.cert_ci_jenkins_io_sponsorship_vnet.azurerm_resource_group.vnet_rg[0]
}
moved {
  from = azurerm_resource_group.infra_ci_jenkins_io_sponsorship
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_resource_group.vnet_rg[0]
}

## Virtual networks
moved {
  from = azurerm_virtual_network.public
  to   = module.public_vnet.azurerm_virtual_network.vnet
}
moved {
  from = azurerm_virtual_network.public_jenkins_sponsorship
  to   = module.public_sponsorship_vnet.azurerm_virtual_network.vnet
}
moved {
  from = azurerm_virtual_network.private
  to   = module.private_vnet.azurerm_virtual_network.vnet
}
moved {
  from = azurerm_virtual_network.trusted_ci_jenkins_io
  to   = module.trusted_ci_jenkins_io_vnet.azurerm_virtual_network.vnet
}
moved {
  from = azurerm_virtual_network.trusted_ci_jenkins_io_sponsorship
  to   = module.trusted_ci_jenkins_io_sponsorship_vnet.azurerm_virtual_network.vnet
}
moved {
  from = azurerm_virtual_network.cert_ci_jenkins_io
  to   = module.cert_ci_jenkins_io_vnet.azurerm_virtual_network.vnet
}
moved {
  from = azurerm_virtual_network.cert_ci_jenkins_io_sponsorship
  to   = module.cert_ci_jenkins_io_sponsorship_vnet.azurerm_virtual_network.vnet
}
moved {
  from = azurerm_virtual_network.infra_ci_jenkins_io_sponsorship
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_virtual_network.vnet
}
moved {
  from = azurerm_virtual_network.public_db
  to   = module.public_db_vnet.azurerm_virtual_network.vnet
}

## Subnets
moved {
  from = azurerm_subnet.publick8s_tier
  to   = module.public_vnet.azurerm_subnet.vnet_subnets["publick8s-tier"]
}
moved {
  from = azurerm_subnet.public_vnet_data_tier
  to   = module.public_vnet.azurerm_subnet.vnet_subnets["public-vnet-data-tier"]
}
moved {
  from = azurerm_subnet.public_vnet_ci_jenkins_io_agents
  to   = module.public_vnet.azurerm_subnet.vnet_subnets["public-vnet-ci_jenkins_io_agents"]
}
moved {
  from = azurerm_subnet.public_vnet_ci_jenkins_io_controller
  to   = module.public_vnet.azurerm_subnet.vnet_subnets["public-vnet-ci_jenkins_io_controller"]
}
moved {
  from = azurerm_subnet.dmz
  to   = module.private_vnet.azurerm_subnet.vnet_subnets["private-vnet-dmz"]
}
moved {
  from = azurerm_subnet.private_vnet_data_tier
  to   = module.private_vnet.azurerm_subnet.vnet_subnets["private-vnet-data-tier"]
}
moved {
  from = azurerm_subnet.privatek8s_tier
  to   = module.private_vnet.azurerm_subnet.vnet_subnets["privatek8s-tier"]
}
moved {
  from = azurerm_subnet.privatek8s_release_tier
  to   = module.private_vnet.azurerm_subnet.vnet_subnets["privatek8s-release-tier"]
}
moved {
  from = azurerm_subnet.privatek8s_infra_ci_controller_tier
  to   = module.private_vnet.azurerm_subnet.vnet_subnets["privatek8s-infraci-ctrl-tier"]
}
moved {
  from = azurerm_subnet.privatek8s_release_ci_controller_tier
  to   = module.private_vnet.azurerm_subnet.vnet_subnets["privatek8s-releaseci-ctrl-tier"]
}
moved {
  from = azurerm_subnet.public_jenkins_sponsorship_vnet_ci_jenkins_io_agents
  to   = module.public_sponsorship_vnet.azurerm_subnet.vnet_subnets["public-jenkins-sponsorship-vnet-ci_jenkins_io_agents"]
}
moved {
  from = azurerm_subnet.ci_jenkins_io_controller_sponsorship
  to   = module.public_sponsorship_vnet.azurerm_subnet.vnet_subnets["public-jenkins-sponsorship-vnet-ci_jenkins_io_controller"]
}
moved {
  from = azurerm_subnet.ci_jenkins_io_kubernetes_sponsorship
  to   = module.public_sponsorship_vnet.azurerm_subnet.vnet_subnets["public-jenkins-sponsorship-vnet-ci_jenkins_io_kubernetes"]
}
moved {
  from = azurerm_subnet.trusted_ci_jenkins_io_controller
  to   = module.trusted_ci_jenkins_io_vnet.azurerm_subnet.vnet_subnets["trusted-ci-jenkins-io-vnet-controller"]
}
moved {
  from = azurerm_subnet.trusted_ci_jenkins_io_ephemeral_agents
  to   = module.trusted_ci_jenkins_io_vnet.azurerm_subnet.vnet_subnets["trusted-ci-jenkins-io-vnet-ephemeral-agents"]
}
moved {
  from = azurerm_subnet.trusted_ci_jenkins_io_permanent_agents
  to   = module.trusted_ci_jenkins_io_vnet.azurerm_subnet.vnet_subnets["trusted-ci-jenkins-io-vnet-permanent-agents"]
}
moved {
  from = azurerm_subnet.trusted_ci_jenkins_io_sponsorship_ephemeral_agents
  to   = module.trusted_ci_jenkins_io_sponsorship_vnet.azurerm_subnet.vnet_subnets["trusted-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"]
}
moved {
  from = azurerm_subnet.cert_ci_jenkins_io_controller
  to   = module.cert_ci_jenkins_io_vnet.azurerm_subnet.vnet_subnets["cert-ci-jenkins-io-vnet-controller"]
}
moved {
  from = azurerm_subnet.cert_ci_jenkins_io_ephemeral_agents
  to   = module.cert_ci_jenkins_io_vnet.azurerm_subnet.vnet_subnets["cert-ci-jenkins-io-vnet-ephemeral-agents"]
}
moved {
  from = azurerm_subnet.cert_ci_jenkins_io_sponsorship_ephemeral_agents
  to   = module.cert_ci_jenkins_io_sponsorship_vnet.azurerm_subnet.vnet_subnets["cert-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"]
}
moved {
  from = azurerm_subnet.infra_ci_jenkins_io_kubernetes_agent_sponsorship
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_subnet.vnet_subnets["infra-ci-jenkins-io-sponsorship-vnet-kubernetes-agents"]
}
moved {
  from = azurerm_subnet.infra_ci_jenkins_io_sponsorship_ephemeral_agents
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_subnet.vnet_subnets["infra-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"]
}
moved {
  from = azurerm_subnet.infra_ci_jenkins_io_sponsorship_packer_builds
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_subnet.vnet_subnets["infra-ci-jenkins-io-sponsorship-vnet-packer-builds"]
}
moved {
  from = azurerm_subnet.public_db_vnet_postgres_tier
  to   = module.public_db_vnet.azurerm_subnet.vnet_subnets["public-db-vnet-postgres-tier"]
}
moved {
  from = azurerm_subnet.public_db_vnet_mysql_tier
  to   = module.public_db_vnet.azurerm_subnet.vnet_subnets["public-db-vnet-mysql-tier"]
}

## Peerings
moved {
  from = azurerm_virtual_network_peering.public_to_private
  to   = module.public_vnet.azurerm_virtual_network_peering.vnet_peering["private-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.private_to_public
  to   = module.private_vnet.azurerm_virtual_network_peering.vnet_peering["public-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.public_sponsorship_to_private
  to   = module.public_sponsorship_vnet.azurerm_virtual_network_peering.vnet_peering["private-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.public_sponsorship_to_infraci_jenkins_sponsorship
  to   = module.public_sponsorship_vnet.azurerm_virtual_network_peering.vnet_peering["infra-ci-jenkins-io-sponsorship-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.public_jenkins_sponsorship_to_public
  to   = module.public_sponsorship_vnet.azurerm_virtual_network_peering.vnet_peering["public-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.public_to_public_db
  to   = module.public_vnet.azurerm_virtual_network_peering.vnet_peering["public-db-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.public_to_public_jenkins_sponsorship
  to   = module.public_vnet.azurerm_virtual_network_peering.vnet_peering["public-jenkins-sponsorship-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.private_to_public_db
  to   = module.private_vnet.azurerm_virtual_network_peering.vnet_peering["public-db-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.private_to_public_sponsorship
  to   = module.private_vnet.azurerm_virtual_network_peering.vnet_peering["public-jenkins-sponsorship-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.private_to_cert
  to   = module.private_vnet.azurerm_virtual_network_peering.vnet_peering["cert-ci-jenkins-io-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.private_to_trusted
  to   = module.private_vnet.azurerm_virtual_network_peering.vnet_peering["trusted-ci-jenkins-io-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.private_to_infraci_jenkins_sponsorship
  to   = module.private_vnet.azurerm_virtual_network_peering.vnet_peering["infra-ci-jenkins-io-sponsorship-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.trusted_to_private
  to   = module.trusted_ci_jenkins_io_vnet.azurerm_virtual_network_peering.vnet_peering["private-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.trusted_to_trusted_jenkins_sponsorship
  to   = module.trusted_ci_jenkins_io_vnet.azurerm_virtual_network_peering.vnet_peering["trusted-ci-jenkins-io-sponsorship-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.cert_to_cert_jenkins_sponsorship
  to   = module.cert_ci_jenkins_io_vnet.azurerm_virtual_network_peering.vnet_peering["cert-ci-jenkins-io-sponsorship-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.cert_to_private
  to   = module.cert_ci_jenkins_io_vnet.azurerm_virtual_network_peering.vnet_peering["private-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.cert_jenkins_sponsorship_to_cert
  to   = module.cert_ci_jenkins_io_sponsorship_vnet.azurerm_virtual_network_peering.vnet_peering["cert-ci-jenkins-io-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.infraci_jenkins_sponsorship_to_public_sponsorship
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_virtual_network_peering.vnet_peering["public-jenkins-sponsorship-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.infraci_jenkins_sponsorship_to_public_db
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_virtual_network_peering.vnet_peering["public-db-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.infraci_jenkins_sponsorship_to_private
  to   = module.infra_ci_jenkins_io_sponsorship_vnet.azurerm_virtual_network_peering.vnet_peering["private-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.public_db_to_infraci_jenkins_sponsorship
  to   = module.public_db_vnet.azurerm_virtual_network_peering.vnet_peering["infra-ci-jenkins-io-sponsorship-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.public_db_to_public
  to   = module.public_db_vnet.azurerm_virtual_network_peering.vnet_peering["public-vnet"]
}
moved {
  from = azurerm_virtual_network_peering.public_db_to_private
  to   = module.public_db_vnet.azurerm_virtual_network_peering.vnet_peering["private-vnet"]
}

# Gateways
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["infra-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"]
  to   = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["infra-ci-jenkins-io-sponsorship-vnet-packer-builds"]
  to   = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[1]
}
moved {
  from = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["infra-ci-jenkins-io-sponsorship-vnet-kubernetes-agents"]
  to   = module.infra_ci_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[2]
}
moved {
  from = module.publick8s_outbound.azurerm_subnet_nat_gateway_association.outbound["publick8s-tier"]
  to   = module.publick8s_outbound.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.cert_ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound["cert-ci-jenkins-io-vnet-controller"]
  to   = module.cert_ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.cert_ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound["cert-ci-jenkins-io-vnet-ephemeral-agents"]
  to   = module.cert_ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound[1]
}
moved {
  from = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["cert-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"]
  to   = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["public-jenkins-sponsorship-vnet-ci_jenkins_io_agents"]
  to   = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[1]
}
moved {
  from = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["public-jenkins-sponsorship-vnet-ci_jenkins_io_kubernetes"]
  to   = module.cert_ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[2]
}
moved {
  from = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-vnet-ephemeral-agents"]
  to   = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound[2]
}
moved {
  from = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-vnet-permanent-agents"]
  to   = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound[1]
}
moved {
  from = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-vnet-controller"]
  to   = module.trusted_outbound.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.trusted_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["trusted-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"]
  to   = module.trusted_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound["public-vnet-ci_jenkins_io_controller"]
  to   = module.ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound["public-vnet-ci_jenkins_io_agents"]
  to   = module.ci_jenkins_io_outbound.azurerm_subnet_nat_gateway_association.outbound[1]
}
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["public-jenkins-sponsorship-vnet-ci_jenkins_io_agents"]
  to   = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["public-jenkins-sponsorship-vnet-ci_jenkins_io_controller"]
  to   = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[1]
}
moved {
  from = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound["public-jenkins-sponsorship-vnet-ci_jenkins_io_kubernetes"]
  to   = module.ci_jenkins_io_outbound_sponsorship.azurerm_subnet_nat_gateway_association.outbound[2]
}
moved {
  from = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound["privatek8s-tier"]
  to   = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound[0]
}
moved {
  from = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound["privatek8s-release-tier"]
  to   = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound[1]
}
moved {
  from = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound["private-vnet-data-tier"]
  to   = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound[2]
}
moved {
  from = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound["privatek8s-infraci-ctrl-tier"]
  to   = module.privatek8s_outbound.azurerm_subnet_nat_gateway_association.outbound[3]
}
moved {
  from = azurerm_virtual_network_peering.trusted_jenkins_sponsorship_to_trusted
  to   = module.trusted_ci_jenkins_io_sponsorship_vnet.azurerm_virtual_network_peering.vnet_peering["trusted-ci-jenkins-io-vnet"]
}
