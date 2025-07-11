variable "search_service_name" {
  description = "Name of the Azure Cognitive Search service"
  type        = string
}

variable "search_sku_name" {
  description = "SKU name for the Azure Cognitive Search service"
  type        = string
  default     = "basic"
}

variable "form_recognizer_name" {
  description = "Name of the Azure Form Recognizer service"
  type        = string
}

variable "form_recognizer_sku_name" {
  description = "SKU name for the Azure Form Recognizer service"
  type        = string
  default     = "S0"
}

variable "openai_service_name" {
  description = "Name of the Azure OpenAI service"
  type        = string
}

variable "openai_sku_name" {
  description = "SKU name for the Azure OpenAI service"
  type        = string
  default     = "S0"
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