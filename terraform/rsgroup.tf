resource "azurerm_resource_group" "mattermost" {
  name     = "${var.prefix}-aks"
  location = var.location
}

