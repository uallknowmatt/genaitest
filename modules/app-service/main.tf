# Azure App Service Plan for Web Application (Free tier)
resource "azurerm_service_plan" "web" {
  name                = var.web_app_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Windows"
  sku_name            = "F1"  # Free tier
  
  tags = var.tags
}

# Azure Web App (Free tier)
resource "azurerm_windows_web_app" "app" {
  name                = var.web_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.web.id
  
  site_config {
    application_stack {
      dotnet_version = "v6.0"
    }
  }
  
  app_settings = {
    "STORAGE_CONNECTION_STRING" = var.storage_connection_string
    "SEARCH_ENDPOINT"           = var.search_endpoint
    "SEARCH_API_KEY"            = var.search_api_key
    "OPENAI_ENDPOINT"           = var.openai_endpoint
    "OPENAI_API_KEY"            = var.openai_api_key
    "SQL_CONNECTION_STRING"     = var.sql_connection_string
    "KEY_VAULT_URL"             = var.key_vault_url
  }
  
  tags = var.tags
}

# Azure Functions App Service Plan (Consumption plan - pay per use)
resource "azurerm_service_plan" "functions" {
  name                = var.functions_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Windows"
  sku_name            = "Y1"  # Consumption plan - only pay when used
  
  tags = var.tags
}

# Azure Functions App (Consumption plan)
resource "azurerm_windows_function_app" "functions" {
  name                       = var.functions_app_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.functions.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  
  site_config {
    application_stack {
      dotnet_version = "v6.0"
    }
  }
  
  app_settings = {
    "STORAGE_CONNECTION_STRING" = var.storage_connection_string
    "SEARCH_ENDPOINT"           = var.search_endpoint
    "SEARCH_API_KEY"            = var.search_api_key
    "OPENAI_ENDPOINT"           = var.openai_endpoint
    "OPENAI_API_KEY"            = var.openai_api_key
    "SQL_CONNECTION_STRING"     = var.sql_connection_string
    "HOT_CONTAINER_NAME"        = "hot-documents"
    "ARCHIVE_CONTAINER_NAME"    = "archive"
    "METADATA_CONTAINER_NAME"   = "metadata"
    "ACCESS_THRESHOLD_DAYS"     = "30"
    "ARCHIVE_THRESHOLD_DAYS"    = "90"
  }
  
  tags = var.tags
} 