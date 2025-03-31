output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "kube_config" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
}
