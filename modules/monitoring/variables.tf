variable "logic_app_name" {
  description = "Name of the Logic App for document management"
  type        = string
}

variable "app_insights_name" {
  description = "Name of the Application Insights for monitoring"
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 