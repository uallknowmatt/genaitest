variable "web_app_plan_name" {
  description = "Name of the App Service Plan for web application"
  type        = string
}

variable "web_app_plan_sku_name" {
  description = "SKU name for the App Service Plan"
  type        = string
  default     = "B1"
}

variable "web_app_name" {
  description = "Name of the web application"
  type        = string
}

variable "functions_plan_name" {
  description = "Name of the App Service Plan for functions"
  type        = string
}

variable "functions_app_name" {
  description = "Name of the functions application"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "storage_connection_string" {
  description = "Connection string for the storage account"
  type        = string
  sensitive   = true
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "storage_account_access_key" {
  description = "Access key for the storage account"
  type        = string
  sensitive   = true
}

variable "search_endpoint" {
  description = "Endpoint for the search service"
  type        = string
}

variable "search_api_key" {
  description = "API key for the search service"
  type        = string
  sensitive   = true
}

variable "openai_endpoint" {
  description = "Endpoint for the OpenAI service"
  type        = string
}

variable "openai_api_key" {
  description = "API key for the OpenAI service"
  type        = string
  sensitive   = true
}

variable "sql_connection_string" {
  description = "Connection string for the SQL database"
  type        = string
  sensitive   = true
}

variable "key_vault_url" {
  description = "URL for the Key Vault"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 