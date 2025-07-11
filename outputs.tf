output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Location of the created resource group"
  value       = azurerm_resource_group.rg.location
}

# Storage Account Outputs
output "storage_account_name" {
  description = "Name of the created storage account"
  value       = azurerm_storage_account.documents.name
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.documents.primary_access_key
  sensitive   = true
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint for the storage account"
  value       = azurerm_storage_account.documents.primary_blob_endpoint
}

output "storage_connection_string" {
  description = "Connection string for the storage account"
  value       = azurerm_storage_account.documents.primary_connection_string
  sensitive   = true
}

# SQL Database Outputs
output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.database.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.database.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.main.name
}

# Cognitive Search Outputs
output "search_service_name" {
  description = "Name of the Azure Cognitive Search service"
  value       = azurerm_search_service.search.name
}

output "search_service_endpoint" {
  description = "Endpoint URL of the search service"
  value       = azurerm_search_service.search.primary_access_key
}

# OpenAI Outputs
output "openai_account_name" {
  description = "Name of the Azure OpenAI account"
  value       = azurerm_cognitive_account.openai.name
}

output "openai_endpoint" {
  description = "Endpoint URL of the OpenAI service"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "openai_api_key" {
  description = "API key for the OpenAI service"
  value       = azurerm_cognitive_account.openai.primary_access_key
  sensitive   = true
}

# Bot Service Outputs
output "bot_name" {
  description = "Name of the Azure Bot Service"
  value       = azurerm_bot_service_azure_bot.chatbot.name
}

# App Service Outputs
output "app_service_name" {
  description = "Name of the App Service"
  value       = azurerm_windows_web_app.app.name
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = "https://${azurerm_windows_web_app.app.default_hostname}"
}

# Functions Outputs
output "functions_app_name" {
  description = "Name of the Functions App"
  value       = azurerm_windows_function_app.functions.name
}

output "functions_app_url" {
  description = "URL of the Functions App"
  value       = "https://${azurerm_windows_function_app.functions.default_hostname}"
}

# Key Vault Outputs
output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.vault.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.vault.vault_uri
}

# Container Names
output "documents_container_name" {
  description = "Name of the documents container"
  value       = azurerm_storage_container.documents.name
}

output "processed_container_name" {
  description = "Name of the processed documents container"
  value       = azurerm_storage_container.processed.name
} 