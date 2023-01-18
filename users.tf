resource "azuread_group" "aks_group_admin" {
  display_name            = "AKS Administrators"
  security_enabled        = true
  prevent_duplicate_names = true
}

resource "azuread_group_member" "aks_assign_admin" {
  group_object_id  = azuread_group.aks_group_admin.object_id
  member_object_id = data.azurerm_client_config.current.object_id
  depends_on = [
    azuread_group.aks_group_admin
  ]
}

