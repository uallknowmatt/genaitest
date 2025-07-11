variable "bot_name" {
  description = "Name of the bot service"
  type        = string
}

variable "bot_sku_name" {
  description = "SKU name for the bot service"
  type        = string
  default     = "F0"
}

variable "bot_app_id" {
  description = "Microsoft App ID for the bot"
  type        = string
}

variable "bot_app_password" {
  description = "Microsoft App password for the bot"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 