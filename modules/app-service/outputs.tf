output "web_app_plan_id" {
  description = "ID of the web App Service Plan"
  value       = azurerm_service_plan.web.id
}

output "web_app_id" {
  description = "ID of the web application"
  value       = azurerm_windows_web_app.app.id
}

output "web_app_name" {
  description = "Name of the web application"
  value       = azurerm_windows_web_app.app.name
}

output "web_app_url" {
  description = "URL of the web application"
  value       = "https://${azurerm_windows_web_app.app.default_hostname}"
}

output "functions_plan_id" {
  description = "ID of the functions App Service Plan"
  value       = azurerm_service_plan.functions.id
}

output "functions_app_id" {
  description = "ID of the functions application"
  value       = azurerm_windows_function_app.functions.id
}

output "functions_app_name" {
  description = "Name of the functions application"
  value       = azurerm_windows_function_app.functions.name
}

output "functions_app_url" {
  description = "URL of the functions application"
  value       = "https://${azurerm_windows_function_app.functions.default_hostname}"
} 