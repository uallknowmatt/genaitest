output "bot_id" {
  description = "ID of the bot service"
  value       = azurerm_bot_service_azure_bot.bot.id
}

output "bot_name" {
  description = "Name of the bot service"
  value       = azurerm_bot_service_azure_bot.bot.name
}

output "bot_endpoint" {
  description = "Endpoint of the bot service"
  value       = azurerm_bot_service_azure_bot.bot.endpoint
} 