# Azure Key Vault
resource "azurerm_key_vault" "main" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  
  tags = var.tags
}

# Key Vault Access Policy for current user
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover", "Purge"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover", "Purge"
  ]

  certificate_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover", "Purge"
  ]
}

# Data source for current Azure client
data "azurerm_client_config" "current" {} 