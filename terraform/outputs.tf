output "rsgroup" {
  value = "${azurerm_resource_group.mattermost.name}"
}

output "cluster_id" {
  value = "${azurerm_kubernetes_cluster.mattermost.id}"
}

output "client_key" {
  value = "${azurerm_kubernetes_cluster.mattermost.kube_config.0.client_key}"
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.mattermost.kube_config.0.client_certificate}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.mattermost.kube_config_raw}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.mattermost.kube_config.0.host}"
}

output "ala_workspace_id" {
  value = "${azurerm_log_analytics_workspace.mattermost.workspace_id}"
}

output "ala_shared_key" {
  value = "${azurerm_log_analytics_workspace.mattermost.primary_shared_key}"
}

output "kv_name" {
  value = "${azurerm_key_vault.mattermost.name}"
}

output "test" {
  value = "${azurerm_key_vault_secret.mattermost.value}"
}
