resource "azurerm_key_vault_secret" "mattermost" {
  name         = "config"
  value        = "${var.secret}"
  key_vault_id = "${azurerm_key_vault.mattermost.id}"

  tags = {
    environment = "Production"
  }
}
