data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "mattermost" {
  name                        = "${var.prefix}-vault"
  location                    = "${azurerm_resource_group.mattermost.location}"
  resource_group_name         = "${azurerm_resource_group.mattermost.name}"
  enabled_for_disk_encryption = true
  tenant_id                   = "${var.tenant_id}"

  sku {
    name = "standard"
  }
  #sku_name = "standard"

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${data.azurerm_client_config.current.service_principal_object_id}"

    secret_permissions = [
      "get",
      "list",
      "set",
      "delete",
    ]
  }

  access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "${var.client_id}"

    secret_permissions = [
      "get",
      "list",
      "set",
      "delete",
    ]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = {
    environment = "Production"
  }
}
