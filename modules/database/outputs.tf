output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = azurerm_mssql_server.database.id
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.database.name
}

output "sql_server_fully_qualified_domain_name" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.database.fully_qualified_domain_name
}

output "sql_database_id" {
  description = "ID of the SQL Database"
  value       = azurerm_mssql_database.main.id
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.main.name
}

output "sql_connection_string" {
  description = "Connection string for the SQL Database"
  value       = "Server=tcp:${azurerm_mssql_server.database.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
} 