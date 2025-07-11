# Resource Group Outputs
output "resource_group_id" {
  description = "ID of the resource group"
  value       = module.resource_group.resource_group_id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.resource_group_name
}

# Storage Outputs
output "storage_account_id" {
  description = "ID of the storage account"
  value       = module.storage.storage_account_id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage.storage_account_name
}

output "storage_account_endpoint" {
  description = "Primary blob endpoint for the storage account"
  value       = module.storage.storage_account_endpoint
}

# Database Outputs
output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = module.database.sql_server_id
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = module.database.sql_server_name
}

output "sql_database_id" {
  description = "ID of the SQL Database"
  value       = module.database.sql_database_id
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = module.database.sql_database_name
}

# Cognitive Services Outputs
output "search_service_id" {
  description = "ID of the Azure Cognitive Search service"
  value       = module.cognitive_services.search_service_id
}

output "search_service_name" {
  description = "Name of the Azure Cognitive Search service"
  value       = module.cognitive_services.search_service_name
}

output "form_recognizer_id" {
  description = "ID of the Azure Form Recognizer service"
  value       = module.cognitive_services.form_recognizer_id
}

output "form_recognizer_name" {
  description = "Name of the Azure Form Recognizer service"
  value       = module.cognitive_services.form_recognizer_name
}

output "openai_id" {
  description = "ID of the Azure OpenAI service"
  value       = module.cognitive_services.openai_id
}

output "openai_name" {
  description = "Name of the Azure OpenAI service"
  value       = module.cognitive_services.openai_name
}

# Key Vault Outputs
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.key_vault.key_vault_id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.key_vault_uri
}

# App Service Outputs
output "web_app_id" {
  description = "ID of the web application"
  value       = module.app_service.web_app_id
}

output "web_app_name" {
  description = "Name of the web application"
  value       = module.app_service.web_app_name
}

output "web_app_url" {
  description = "URL of the web application"
  value       = module.app_service.web_app_url
}

output "functions_app_id" {
  description = "ID of the functions application"
  value       = module.app_service.functions_app_id
}

output "functions_app_name" {
  description = "Name of the functions application"
  value       = module.app_service.functions_app_name
}

output "functions_app_url" {
  description = "URL of the functions application"
  value       = module.app_service.functions_app_url
}

# Bot Service Outputs
output "bot_id" {
  description = "ID of the bot service"
  value       = module.bot_service.bot_id
}

output "bot_name" {
  description = "Name of the bot service"
  value       = module.bot_service.bot_name
}

output "bot_endpoint" {
  description = "Endpoint of the bot service"
  value       = module.bot_service.bot_endpoint
}

# Monitoring Outputs
output "logic_app_id" {
  description = "ID of the Logic App"
  value       = module.monitoring.logic_app_id
}

output "logic_app_name" {
  description = "Name of the Logic App"
  value       = module.monitoring.logic_app_name
}

output "app_insights_id" {
  description = "ID of the Application Insights"
  value       = module.monitoring.app_insights_id
}

output "app_insights_name" {
  description = "Name of the Application Insights"
  value       = module.monitoring.app_insights_name
} 