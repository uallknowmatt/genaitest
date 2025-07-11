# Storage Account for Document Storage with Free Tier Optimization
resource "azurerm_storage_account" "documents" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  # Use cool tier for cost optimization
  access_tier = "Cool"
  
  blob_properties {
    versioning_enabled = false  # Disable to save costs
    delete_retention_policy {
      days = 7  # Reduced retention to save costs
    }
    
    # Simplified lifecycle management
    container_delete_retention_policy {
      days = 1
    }
  }
  
  tags = var.tags
}

# Simplified Storage Management Policy
resource "azurerm_storage_management_policy" "documents" {
  storage_account_id = azurerm_storage_account.documents.id

  rule {
    name    = "DocumentLifecycleRule"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
      prefix_match = ["documents/", "processed/"]
    }

    actions {
      # Simplified tiering - move to archive after 30 days
      base_blob {
        tier_to_archive_after_days_since_last_access_time_greater_than = 30
        delete_after_days_since_last_access_time_greater_than = 90
      }
    }
  }
}

# Minimal Storage Containers
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