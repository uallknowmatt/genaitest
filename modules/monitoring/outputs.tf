output "logic_app_id" {
  description = "ID of the Logic App"
  value       = azurerm_logic_app_workflow.document_manager.id
}

output "logic_app_name" {
  description = "Name of the Logic App"
  value       = azurerm_logic_app_workflow.document_manager.name
}

output "app_insights_id" {
  description = "ID of the Application Insights"
  value       = azurerm_application_insights.document_monitor.id
}

output "app_insights_name" {
  description = "Name of the Application Insights"
  value       = azurerm_application_insights.document_monitor.name
}

output "app_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = azurerm_application_insights.document_monitor.instrumentation_key
  sensitive   = true
} 