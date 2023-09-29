# This data source allows referencing the identity used by Terraform to connect to the Azure API
data "azuread_service_principal" "terraform-azure-net-production" {
  display_name = "terraform-azure-net-production"
}

module "jenkins_infra_shared_data" {
  source = "./.shared-tools/terraform/modules/jenkins-infra-shared-data"
}
