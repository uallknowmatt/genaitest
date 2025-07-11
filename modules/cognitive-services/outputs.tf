output "search_service_id" {
  description = "ID of the Azure Cognitive Search service"
  value       = azurerm_search_service.search.id
}

output "search_service_name" {
  description = "Name of the Azure Cognitive Search service"
  value       = azurerm_search_service.search.name
}

output "search_service_primary_key" {
  description = "Primary key for the Azure Cognitive Search service"
  value       = azurerm_search_service.search.primary_key
  sensitive   = true
}

output "search_service_endpoint" {
  description = "Endpoint for the Azure Cognitive Search service"
  value       = azurerm_search_service.search.primary_endpoint
}

output "form_recognizer_id" {
  description = "ID of the Azure Form Recognizer service"
  value       = azurerm_cognitive_account.form_recognizer.id
}

output "form_recognizer_name" {
  description = "Name of the Azure Form Recognizer service"
  value       = azurerm_cognitive_account.form_recognizer.name
}

output "form_recognizer_endpoint" {
  description = "Endpoint for the Azure Form Recognizer service"
  value       = azurerm_cognitive_account.form_recognizer.endpoint
}

output "form_recognizer_primary_key" {
  description = "Primary key for the Azure Form Recognizer service"
  value       = azurerm_cognitive_account.form_recognizer.primary_access_key
  sensitive   = true
}

output "openai_id" {
  description = "ID of the Azure OpenAI service"
  value       = azurerm_cognitive_account.openai.id
}

output "openai_name" {
  description = "Name of the Azure OpenAI service"
  value       = azurerm_cognitive_account.openai.name
}

output "openai_endpoint" {
  description = "Endpoint for the Azure OpenAI service"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "openai_primary_key" {
  description = "Primary key for the Azure OpenAI service"
  value       = azurerm_cognitive_account.openai.primary_access_key
  sensitive   = true
} 