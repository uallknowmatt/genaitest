# Azure Cognitive Search Service (Basic tier - minimal cost)
resource "azurerm_search_service" "search" {
  name                = var.search_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "basic"  # Free tier equivalent
  
  tags = var.tags
}

# Azure Cognitive Services Account for Form Recognizer (Free tier)
resource "azurerm_cognitive_account" "form_recognizer" {
  name                = var.form_recognizer_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FormRecognizer"
  sku_name            = "F0"  # Free tier
  
  tags = var.tags
}

# Azure OpenAI Service (Free tier if available)
resource "azurerm_cognitive_account" "openai" {
  name                = var.openai_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = "F0"  # Free tier if available, otherwise S0
  
  tags = var.tags
} 