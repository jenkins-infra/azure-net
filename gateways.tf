####################################################################################
## NAT gateway to allow outbound connection on a centralized and scalable appliance
####################################################################################

module "cert_ci_jenkins_io_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "cert-ci-jenkins-io-outbound"
  resource_group_name = module.cert_ci_jenkins_io_vnet.vnet_rg_name
  vnet_name           = module.cert_ci_jenkins_io_vnet.vnet_name
  subnet_ids = [
    module.cert_ci_jenkins_io_vnet.subnets["cert-ci-jenkins-io-vnet-controller"],
    module.cert_ci_jenkins_io_vnet.subnets["cert-ci-jenkins-io-vnet-ephemeral-agents"],
  ]
}

module "cert_ci_jenkins_io_outbound_sponsorship" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  name                = "cert-ci-jenkins-io-outbound-sponsorship"
  resource_group_name = module.cert_ci_jenkins_io_sponsorship_vnet.vnet_rg_name
  vnet_name           = module.cert_ci_jenkins_io_sponsorship_vnet.vnet_name
  subnet_ids = [
    module.cert_ci_jenkins_io_sponsorship_vnet.subnets["cert-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"],
  ]

  outbound_ip_count = 2
}

module "trusted_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "trusted-outbound"
  resource_group_name = module.trusted_ci_jenkins_io_vnet.vnet_rg_name
  vnet_name           = module.trusted_ci_jenkins_io_vnet.vnet_name
  subnet_ids = [
    module.trusted_ci_jenkins_io_vnet.subnets["trusted-ci-jenkins-io-vnet-controller"],
    module.trusted_ci_jenkins_io_vnet.subnets["trusted-ci-jenkins-io-vnet-permanent-agents"],
    module.trusted_ci_jenkins_io_vnet.subnets["trusted-ci-jenkins-io-vnet-ephemeral-agents"],
  ]
}

module "trusted_outbound_sponsorship" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  name                = "trusted-outbound-sponsorship"
  resource_group_name = module.trusted_ci_jenkins_io_sponsorship_vnet.vnet_rg_name
  vnet_name           = module.trusted_ci_jenkins_io_sponsorship_vnet.vnet_name
  subnet_ids = [
    module.trusted_ci_jenkins_io_sponsorship_vnet.subnets["trusted-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"],
  ]
  outbound_ip_count = 3
}

module "ci_jenkins_io_outbound_sponsorship" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  name                = "ci-jenkins-io-outbound-sponsorship"
  resource_group_name = module.public_sponsorship_vnet.vnet_rg_name
  vnet_name           = module.public_sponsorship_vnet.vnet_name
  subnet_ids = [
    module.public_sponsorship_vnet.subnets["public-jenkins-sponsorship-vnet-ci_jenkins_io_agents"],
    module.public_sponsorship_vnet.subnets["public-jenkins-sponsorship-vnet-ci_jenkins_io_controller"],
    module.public_sponsorship_vnet.subnets["public-jenkins-sponsorship-vnet-ci_jenkins_io_kubernetes"],
  ]

  outbound_ip_count = 2
}

module "privatek8s_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "privatek8s-outbound"
  resource_group_name = module.private_vnet.vnet_rg_name
  vnet_name           = module.private_vnet.vnet_name
  subnet_ids = [
    module.private_vnet.subnets["privatek8s-tier"],
    module.private_vnet.subnets["privatek8s-release-tier"],
    module.private_vnet.subnets["private-vnet-data-tier"],
    module.private_vnet.subnets["privatek8s-infraci-ctrl-tier"],
    module.private_vnet.subnets["privatek8s-releaseci-ctrl-tier"],
  ]
}

module "infra_ci_outbound_sponsorship" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  providers = {
    azurerm = azurerm.jenkins-sponsorship
  }

  name                = "infra-ci-outbound-sponsorship"
  resource_group_name = module.infra_ci_jenkins_io_sponsorship_vnet.vnet_rg_name
  vnet_name           = module.infra_ci_jenkins_io_sponsorship_vnet.vnet_name
  subnet_ids = [
    module.infra_ci_jenkins_io_sponsorship_vnet.subnets["infra-ci-jenkins-io-sponsorship-vnet-ephemeral-agents"],
    module.infra_ci_jenkins_io_sponsorship_vnet.subnets["infra-ci-jenkins-io-sponsorship-vnet-packer-builds"],
    module.infra_ci_jenkins_io_sponsorship_vnet.subnets["infra-ci-jenkins-io-sponsorship-vnet-kubernetes-agents"],
  ]

  outbound_ip_count = 2
}

module "publick8s_outbound" {
  source = "./.shared-tools/terraform/modules/azure-nat-gateway"

  name                = "publick8s-outbound"
  resource_group_name = module.public_vnet.vnet_rg_name
  vnet_name           = module.public_vnet.vnet_name
  subnet_ids = [
    module.public_vnet.subnets["publick8s-tier"],
  ]
}
