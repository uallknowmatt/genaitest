output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.documents.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.documents.name
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.documents.primary_access_key
  sensitive   = true
}

output "storage_account_primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = azurerm_storage_account.documents.primary_connection_string
  sensitive   = true
}

output "storage_account_endpoint" {
  description = "Primary blob endpoint for the storage account"
  value       = azurerm_storage_account.documents.primary_blob_endpoint
}

output "containers" {
  description = "Map of container names to their IDs"
  value = {
    documents = azurerm_storage_container.documents.id
    processed = azurerm_storage_container.processed.id
  }
} 