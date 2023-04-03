# This data source allows referencing the identity used by Terraform to connect to the Azure API
data "azuread_service_principal" "terraform-azure-net-production" {
  display_name = "terraform-azure-net-production"
}
