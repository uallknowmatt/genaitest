# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Resource Group Module
module "resource_group" {
  source = "./modules/resource-group"
  
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  
  storage_account_name = var.storage_account_name
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  tags                 = var.tags
}

# Database Module
module "database" {
  source = "./modules/database"
  
  sql_server_name      = var.sql_server_name
  sql_database_name    = var.sql_database_name
  sql_admin_username   = var.sql_admin_username
  sql_admin_password   = var.sql_admin_password
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  tags                 = var.tags
}

# Cognitive Services Module
module "cognitive_services" {
  source = "./modules/cognitive-services"
  
  search_service_name      = var.search_service_name
  form_recognizer_name     = var.form_recognizer_name
  openai_service_name      = var.openai_service_name
  resource_group_name      = module.resource_group.resource_group_name
  location                 = module.resource_group.resource_group_location
  tags                     = var.tags
}

# Key Vault Module
module "key_vault" {
  source = "./modules/key-vault"
  
  key_vault_name      = var.key_vault_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tags                = var.tags
}

# App Service Module
module "app_service" {
  source = "./modules/app-service"
  
  web_app_plan_name           = var.web_app_plan_name
  web_app_name                = var.web_app_name
  functions_plan_name         = var.functions_plan_name
  functions_app_name          = var.functions_app_name
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  storage_connection_string   = module.storage.storage_account_primary_connection_string
  storage_account_name        = module.storage.storage_account_name
  storage_account_access_key  = module.storage.storage_account_primary_access_key
  search_endpoint             = module.cognitive_services.search_service_endpoint
  search_api_key              = module.cognitive_services.search_service_primary_key
  openai_endpoint             = module.cognitive_services.openai_endpoint
  openai_api_key              = module.cognitive_services.openai_primary_key
  sql_connection_string       = module.database.sql_connection_string
  key_vault_url               = module.key_vault.key_vault_uri
  tags                        = var.tags
}

# Bot Service Module
module "bot_service" {
  source = "./modules/bot-service"
  
  bot_name           = var.bot_name
  bot_app_id         = var.bot_app_id
  bot_app_password   = var.bot_app_password
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tags                = var.tags
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
  
  logic_app_name     = var.logic_app_name
  app_insights_name  = var.app_insights_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tags                = var.tags
} 