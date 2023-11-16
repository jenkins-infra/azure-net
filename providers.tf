# Configure the Microsoft Azure Providers
provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}
provider "azurerm" {
  alias                      = "jenkins-sponsorship"
  subscription_id            = "1311c09f-aee0-4d6c-99a4-392c2b543204"
  skip_provider_registration = "true"
  features {}
}
