# Azure SQL Server (Basic tier for minimal cost)
resource "azurerm_mssql_server" "database" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
  
  tags = var.tags
}

# Azure SQL Database (Basic tier - minimal cost)
resource "azurerm_mssql_database" "main" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.database.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2  # Minimum size
  sku_name       = "Basic"  # Free tier equivalent
  
  tags = var.tags
}

# SQL Server Firewall Rule for Azure Services
resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.database.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
} 