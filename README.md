#terraform-aks-mixed-azsql

# Create a AKS cluster with Azure AD Group Authentication using kubelogin and an Azure SQL server importing a database from a backup.

![alt text](https://github.com/leandroscardua/terraform-aks-mixed-azsql/blob/main/AKS-AZSQL.jpg?raw=true)

#
#az login with terraform
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli
#Install Kubelogin
https://github.com/Azure/kubelogin#setup
#
#Linux
#
```
export TF_VAR_wn_user_name=
export TF_VAR_wn_user_password=''
export TF_VAR_azsql_administrator_login=
export TF_VAR_azsql_administrator_login_password=''
```

#Windows
#
#az login with terraform
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli
#Install Kubelogin
https://github.com/Azure/kubelogin#setup-windows
#
```
set TF_VAR_wn_user_name=
set TF_VAR_wn_user_password=''
set TF_VAR_azsql_administrator_login=
set TF_VAR_azsql_administrator_login_password=''
```
#Terraform
# add the variables below, before run it.

terraform init

terraform validate

terraform plan

terraform apply -auto-approve
