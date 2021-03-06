resource "azurerm_kubernetes_cluster" "mattermost" {
  name                = "${var.prefix}-aks"
  location            = "${azurerm_resource_group.mattermost.location}"
  resource_group_name = "${azurerm_resource_group.mattermost.name}"
  dns_prefix          = "${var.prefix}-dns"

  agent_pool_profile {
    name            = "default"
    count           = 2
    vm_size         = "${var.machine_type}"
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  tags = {
    Environment = "Production"
  }
}

