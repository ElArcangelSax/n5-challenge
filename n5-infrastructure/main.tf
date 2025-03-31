terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
#
resource "azurerm_resource_group" "main" {
  name     = "helloapp-rg"
  location = "East US"
}
#
resource "azurerm_kubernetes_cluster" "main" {
  name                = "helloapp-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "helloappaks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2s"
  }
}
#
resource "azurerm_container_registry" "acr" {
  name                = "helloappacr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
}
#
resource "azurerm_key_vault" "secrets" {
  name                = "helloapp-secrets"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "standard"
}
#
resource "null_resource" "deploy" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}
      cd ../apps && \
      helmfile -e dev apply && \
      helmfile -e stage apply
    EOT
  }

  depends_on = [
    azurerm_kubernetes_cluster.main
  ]
}
