
resource "azurerm_resource_group" "azsql" {
  name     = "azsql-${random_string.aksql.id}-rg"
  location = var.location

  depends_on = [
    azuread_group_member.aks_assign_admin
  ]
}

resource "azurerm_mssql_server" "azsql" {
  name                          = "azsql-${random_string.aksql.id}-server"
  resource_group_name           = azurerm_resource_group.azsql.name
  location                      = azurerm_resource_group.azsql.location
  version                       = "12.0"
  administrator_login           = var.azsql_administrator_login
  administrator_login_password  = var.azsql_administrator_login_password
  connection_policy             = "Default"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true
  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_resource_group.azsql
  ]

}


resource "azurerm_mssql_firewall_rule" "azsqlfw" {
  name             = "Allow access to Azure services"
  server_id        = azurerm_mssql_server.azsql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"

  depends_on = [
    azurerm_mssql_server.azsql
  ]
}

resource "azurerm_mssql_database" "azsqldb" {
  name      = "azsql-${random_string.aksql.id}-db"
  server_id = azurerm_mssql_server.azsql.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  sku_name  = "S0"

  import {
    storage_uri                  = "https://${azurerm_storage_account.sa.name}.blob.core.windows.net/bkp/AdventureWorks2019.bacpac"
    storage_key                  = azurerm_storage_account.sa.primary_access_key
    storage_key_type             = "StorageAccessKey"
    administrator_login          = var.azsql_administrator_login
    administrator_login_password = var.azsql_administrator_login_password
    authentication_type          = "Sql"
    #storage_account_id           = azurerm_storage_account.sa.id
  }

  depends_on = [
    azurerm_mssql_server.azsql,
    azurerm_storage_blob.saf
  ]
}
