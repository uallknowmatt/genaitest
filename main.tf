terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Storage Account for Document Storage
resource "azurerm_storage_account" "documents" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
  }
  
  tags = var.tags
}

# Storage Containers
resource "azurerm_storage_container" "documents" {
  name                  = "documents"
  storage_account_name  = azurerm_storage_account.documents.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "processed" {
  name                  = "processed"
  storage_account_name  = azurerm_storage_account.documents.name
  container_access_type = "private"
}

# Azure SQL Database
resource "azurerm_mssql_server" "database" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
  
  tags = var.tags
}

resource "azurerm_mssql_database" "main" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.database.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "Basic"
  
  tags = var.tags
}

# Azure Cognitive Search
resource "azurerm_search_service" "search" {
  name                = var.search_service_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "standard"
  replica_count       = 1
  partition_count     = 1
  
  tags = var.tags
}

# Azure OpenAI Service
resource "azurerm_cognitive_account" "openai" {
  name                = var.openai_account_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"
  sku_name            = "S0"
  
  tags = var.tags
}

# Azure Bot Service
resource "azurerm_bot_service_azure_bot" "chatbot" {
  name                = var.bot_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  microsoft_app_id    = var.bot_app_id
  sku                 = "F0"
  
  tags = var.tags
}

# Azure App Service Plan
resource "azurerm_service_plan" "app" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Windows"
  sku_name            = "B1"
  
  tags = var.tags
}

# Azure App Service (Web App)
resource "azurerm_windows_web_app" "app" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.app.id
  
  site_config {
    application_stack {
      dotnet_version = "v6.0"
    }
    
    app_settings = {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
      "STORAGE_CONNECTION_STRING" = azurerm_storage_account.documents.primary_connection_string
      "SQL_CONNECTION_STRING"     = "Server=tcp:${azurerm_mssql_server.database.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
      "SEARCH_ENDPOINT"           = azurerm_search_service.search.primary_access_key
      "SEARCH_API_KEY"            = azurerm_search_service.search.primary_access_key
      "OPENAI_ENDPOINT"           = azurerm_cognitive_account.openai.endpoint
      "OPENAI_API_KEY"            = azurerm_cognitive_account.openai.primary_access_key
      "BOT_APP_ID"                = var.bot_app_id
      "BOT_APP_PASSWORD"          = var.bot_app_password
    }
  }
  
  tags = var.tags
}

# Azure Functions App Service Plan
resource "azurerm_service_plan" "functions" {
  name                = var.functions_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Windows"
  sku_name            = "Y1" # Consumption plan
  
  tags = var.tags
}

# Azure Functions App
resource "azurerm_windows_function_app" "functions" {
  name                       = var.functions_app_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.functions.id
  storage_account_name       = azurerm_storage_account.documents.name
  storage_account_access_key = azurerm_storage_account.documents.primary_access_key
  
  site_config {
    application_stack {
      dotnet_version = "v6.0"
    }
    
    app_settings = {
      "STORAGE_CONNECTION_STRING" = azurerm_storage_account.documents.primary_connection_string
      "SEARCH_ENDPOINT"           = azurerm_search_service.search.primary_access_key
      "SEARCH_API_KEY"            = azurerm_search_service.search.primary_access_key
      "OPENAI_ENDPOINT"           = azurerm_cognitive_account.openai.endpoint
      "OPENAI_API_KEY"            = azurerm_cognitive_account.openai.primary_access_key
    }
  }
  
  tags = var.tags
}

# Azure Key Vault
resource "azurerm_key_vault" "vault" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  
  tags = var.tags
}

# Key Vault Access Policy for App Service
resource "azurerm_key_vault_access_policy" "app_service" {
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_windows_web_app.app.identity[0].principal_id
  
  secret_permissions = [
    "Get",
    "List"
  ]
}

# App Service Identity
resource "azurerm_windows_web_app" "app_with_identity" {
  name                = azurerm_windows_web_app.app.name
  resource_group_name = azurerm_windows_web_app.app.resource_group_name
  location            = azurerm_windows_web_app.app.location
  service_plan_id     = azurerm_windows_web_app.app.service_plan_id
  
  identity {
    type = "SystemAssigned"
  }
  
  site_config {
    application_stack {
      dotnet_version = "v6.0"
    }
  }
  
  tags = azurerm_windows_web_app.app.tags
}

# Data source for current Azure client
data "azurerm_client_config" "current" {} 