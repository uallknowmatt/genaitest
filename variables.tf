variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = "d8797220-f5cf-4668-a271-39ce114bb150"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-genaitest-dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
  default     = "stgenaitestdev001"
}

variable "container_name" {
  description = "Name of the storage container"
  type        = string
  default     = "data"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "GenAITest"
    ManagedBy   = "Terraform"
  }
} 