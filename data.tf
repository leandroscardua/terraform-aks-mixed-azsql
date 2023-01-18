data "azuread_group" "aks_group_admin" {
  display_name = azuread_group.aks_group_admin.display_name
}

data "azurerm_client_config" "current" {
}
