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
