variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = "d8797220-f5cf-4668-a271-39ce114bb150"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-docai-chatbot-dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
  default     = "stdocai001"
}

variable "container_name" {
  description = "Name of the storage container"
  type        = string
  default     = "data"
}

# SQL Database Variables
variable "sql_server_name" {
  description = "Name of the SQL Server"
  type        = string
  default     = "sql-docai-dev"
}

variable "sql_database_name" {
  description = "Name of the SQL Database"
  type        = string
  default     = "docai-db"
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  default     = "docaiadmin"
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  default     = "DocAI2024!Secure"
  sensitive   = true
}

# Cognitive Search Variables
variable "search_service_name" {
  description = "Name of the Azure Cognitive Search service"
  type        = string
  default     = "search-docai-dev"
}

# Form Recognizer Variables
variable "form_recognizer_name" {
  description = "Name of the Azure Form Recognizer service"
  type        = string
  default     = "formrecognizer-docai-dev"
}

# OpenAI Variables
variable "openai_service_name" {
  description = "Name of the Azure OpenAI service"
  type        = string
  default     = "openai-docai-dev"
}

# Bot Service Variables
variable "bot_name" {
  description = "Name of the Azure Bot Service"
  type        = string
  default     = "bot-docai-chatbot"
}

variable "bot_app_id" {
  description = "Microsoft App ID for the bot"
  type        = string
  default     = ""
}

variable "bot_app_password" {
  description = "Microsoft App password for the bot"
  type        = string
  default     = ""
  sensitive   = true
}

# App Service Variables
variable "web_app_plan_name" {
  description = "Name of the App Service Plan for web app"
  type        = string
  default     = "plan-docai-web"
}

variable "web_app_name" {
  description = "Name of the web application"
  type        = string
  default     = "app-docai-web"
}

# Functions Variables
variable "functions_plan_name" {
  description = "Name of the Functions App Service Plan"
  type        = string
  default     = "plan-docai-functions"
}

variable "functions_app_name" {
  description = "Name of the Functions App"
  type        = string
  default     = "func-docai-processor"
}

# Key Vault Variables
variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "kv-docai-secrets"
}

# Logic App Variables
variable "logic_app_name" {
  description = "Name of the Logic App for document management"
  type        = string
  default     = "logic-docai-manager"
}

# Application Insights Variables
variable "app_insights_name" {
  description = "Name of the Application Insights for monitoring"
  type        = string
  default     = "appi-docai-monitor"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "DocAI-Chatbot"
    ManagedBy   = "Terraform"
    Purpose     = "Document Management and AI Chatbot"
  }
} 