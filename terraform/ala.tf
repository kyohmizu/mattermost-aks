resource "azurerm_log_analytics_workspace" "mattermost" {
  name                = "mattermost"
  location            = "${azurerm_resource_group.mattermost.location}"
  resource_group_name = "${azurerm_resource_group.mattermost.name}"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
