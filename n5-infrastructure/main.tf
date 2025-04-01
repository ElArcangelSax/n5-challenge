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
  tenant_id           = data.azurerm_client_config.current.tenant_id 

  # Política de acceso (que seria en este caso recomendado para producción)
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id # seria el ID de mi usuario/SP de ahora

    key_permissions = [
      "Get", "List", "Create", "Decrypt", "Encrypt"
    ]
  }
}
#
resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.github_actions.principal_id
}
#
resource "azurerm_role_assignment" "kv_crypto" {
  scope                = azurerm_key_vault.secrets.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = azurerm_user_assigned_identity.github_actions.principal_id
}
#
resource "azurerm_user_assigned_identity" "github_actions" {
  name                = "github-actions-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}