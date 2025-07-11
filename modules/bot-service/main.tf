# Azure Bot Service (Free tier)
resource "azurerm_bot_service_azure_bot" "bot" {
  name                = var.bot_name
  resource_group_name = var.resource_group_name
  location            = var.location
  microsoft_app_id    = var.bot_app_id
  sku                 = "F0"  # Free tier
  
  tags = var.tags
} 