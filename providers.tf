# Configure the Microsoft Azure Providers
provider "azurerm" {
  subscription_id                 = "dff2ec18-6a8e-405c-8e45-b7df7465acf0"
  resource_provider_registrations = "none"
  features {}
}
provider "azurerm" {
  alias                           = "jenkins-sponsorship"
  subscription_id                 = "1311c09f-aee0-4d6c-99a4-392c2b543204"
  resource_provider_registrations = "none"
  features {}
}
