# Main Jenkins Subscription, paid by CDF
provider "azurerm" {
  subscription_id                 = "dff2ec18-6a8e-405c-8e45-b7df7465acf0"
  resource_provider_registrations = "none"
  features {}
}

# "Pay as you go" Subscription - https://github.com/jenkins-infra/helpdesk/issues/5003
provider "azurerm" {
  alias                           = "jenkins-sponsored"
  subscription_id                 = "1e7d5219-acbc-4495-8629-bdbb22e9b3ed"
  resource_provider_registrations = "none"
  features {}
}