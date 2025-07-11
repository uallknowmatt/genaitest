# Azure Logic App for Intelligent Document Management
resource "azurerm_logic_app_workflow" "document_manager" {
  name                = var.logic_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  tags = var.tags
}

# Application Insights for monitoring document access patterns
resource "azurerm_application_insights" "document_monitor" {
  name                = var.app_insights_name
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"
  
  tags = var.tags
} 