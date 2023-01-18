resource "random_string" "aksql" {
  length  = "3"
  special = false
  upper   = false
}

resource "azurerm_resource_group" "aks" {
  name     = "aks-${random_string.aksql.id}-rg"
  location = var.location
  depends_on = [
    azuread_group_member.aks_assign_admin
  ]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                          = "aks-${random_string.aksql.id}-cluster"
  kubernetes_version            = var.orchestrator_version
  location                      = azurerm_resource_group.aks.location
  resource_group_name           = azurerm_resource_group.aks.name
  dns_prefix                    = "aks-${random_string.aksql.id}"
  sku_tier                      = "Free"
  public_network_access_enabled = true
  local_account_disabled        = false
  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = [data.azuread_group.aks_group_admin.id]
  }

  default_node_pool {
    name            = "default"
    os_disk_type    = "Managed"
    os_sku          = "Ubuntu"
    os_disk_size_gb = "128"
    node_count      = var.node_pool_count
    vm_size         = var.vm_size_node_pool
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
    service_cidr       = "10.0.0.0/16"
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip     = "10.0.0.10"
  }

  windows_profile {
    admin_password = var.wn_user_password
    admin_username = var.wn_user_name
  }

  identity {
    type = "SystemAssigned"
  }
  depends_on = [
    azurerm_resource_group.aks
  ]

}

resource "azurerm_kubernetes_cluster_node_pool" "aks_win" {
  name                  = "win"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.vm_size_node_pool
  enable_auto_scaling   = false
  node_count            = 1
  os_type               = "Windows"
  os_sku                = "Windows2022"
  os_disk_size_gb       = "128"
  os_disk_type          = "Managed"
  orchestrator_version  = var.orchestrator_version

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "null_resource" "deploy_app" {

  provisioner "local-exec" {
    when = create
    command = nonsensitive(<<EOT
      az aks get-credentials --resource-group ${azurerm_resource_group.aks.name} --name ${azurerm_kubernetes_cluster.aks.name} -a
      kubelogin convert-kubeconfig -l azurecli
      curl -L https://raw.githubusercontent.com/leandroscardua/windows-linux-aks-sample/main/app.yml | sed 's/Data Source=.*/Data Source=tcp:${azurerm_mssql_server.azsql.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.azsqldb.name};Persist Security Info=False;User ID=${var.azsql_administrator_login};Password=${var.azsql_administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;/g' | kubectl apply -f -
      kubectl apply -f https://raw.githubusercontent.com/leandroscardua/windows-linux-aks-sample/main/database.yml
      kubectl apply -f https://raw.githubusercontent.com/leandroscardua/windows-linux-aks-sample/main/svc.yml
      until [[ $(kubectl get service/adventure-app --output=jsonpath='{.status.loadBalancer.ingress[0].ip}') ]]; do sleep 5; done
      echo -e "AdventureWorks Public IP Address"
      kubectl describe services adventure-app | awk '/LoadBalancer Ingress:/ {print $3}'
EOT
    )
  }

  depends_on = [
    azurerm_kubernetes_cluster_node_pool.aks_win,
    azurerm_mssql_database.azsqldb
  ]
}

