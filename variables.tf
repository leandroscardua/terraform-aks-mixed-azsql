variable "location" {
  type    = string
  default = "West Europe"
}

variable "orchestrator_version" {
  type    = string
  default = "1.24.6"
}

variable "vm_size_node_pool" {
  type    = string
  default = "Standard_D2_v2"
}

variable "node_pool_count" {
  type    = string
  default = 1
}

variable "wn_user_name" {
  type    = string
  default = ""
}

variable "wn_user_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "azsql_administrator_login" {
  type    = string
  default = ""
}

variable "azsql_administrator_login_password" {
  type      = string
  default   = ""
  sensitive = true
}



