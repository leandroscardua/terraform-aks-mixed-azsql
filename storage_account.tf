resource "azurerm_storage_account" "sa" {
  name                          = "azsql${random_string.aksql.id}sa"
  resource_group_name           = azurerm_resource_group.azsql.name
  location                      = azurerm_resource_group.azsql.location
  public_network_access_enabled = true
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"

  depends_on = [
    azuread_group_member.aks_assign_admin,
    azurerm_resource_group.azsql
  ]
}

resource "azurerm_storage_container" "sac" {
  name                  = "bkp"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"

  depends_on = [
    azurerm_storage_account.sa
  ]
}

resource "azurerm_storage_blob" "saf" {
  name                   = "AdventureWorks2019.bacpac"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sac.name
  type                   = "Block"
  source                 = "AdventureWorks2019.bacpac"

  depends_on = [
    azurerm_storage_container.sac
  ]
}

#resource "azurerm_storage_account_network_rules" "sanr" {
#  storage_account_id = azurerm_storage_account.sa.id

#  default_action = "Allow"
#  bypass             = ["None"]
#  private_link_access {
#  endpoint_resource_id = azurerm_mssql_server.azsql.id
#  }
#
#  depends_on = [
#    azurerm_storage_blob.saf
#  ]
#}
