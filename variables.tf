## GENERAL ##
variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group"
}
variable "location" {
  type        = string
  description = "Location of resource"
}

## VNET ##
variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
}

## MYSQL ##
variable "mysql_server_name" {
  type        = string
  description = "MySQL Server Name"
}
variable "mysql_server_username" {
  type        = string
  description = "MySQL Server Username"
  default     = "mysqladmin"
}
variable "mysql_server_password" {
  type        = string
  description = "MySQL Server Password. (If empty auto generated password will be set)"
  default     = ""
}
variable "mysql_server_sku" {
  type        = string
  description = "MySQL Server SKU"
  default     = "GP_Gen5_2"
}
variable "mysql_server_storage" {
  type        = number
  description = "MySQL Server Storage in MB"
  default     = 5120
}
variable "mysql_server_version" {
  type        = string
  description = "MySQL Server Version"
  default     = "8.0"
}
variable "mysql_server_settings" {
  type = object({
    auto_grow_enabled                 = bool
    backup_retention_days             = number
    geo_redundant_backup_enabled      = bool
    infrastructure_encryption_enabled = bool
    public_network_access_enabled     = bool
    ssl_enforcement_enabled           = bool
    ssl_minimal_tls_version_enforced  = string
  })
  description = "MySQL Server Configuration"
  default = {
    auto_grow_enabled                 = true
    backup_retention_days             = 7
    geo_redundant_backup_enabled      = false
    infrastructure_encryption_enabled = false
    public_network_access_enabled     = false
    ssl_enforcement_enabled           = true
    ssl_minimal_tls_version_enforced  = "TLS1_2"
  }
}
variable "mysql_server_private_endpoint" {
  type        = string
  description = "MySQL Server Private Endpoint Name"
}
variable "private_endpoint_subnet" {
  type        = string
  description = "Azure Private Endpoint VNet Subnet Address"
  default     = "10.1.1.0/24"
}
locals {
  private_endpoint_subnet_name = "private_endpoint_subnet"
}


## APP PLAN ##
## App Plan
variable "appplan_name" {
  type        = string
  description = "App Plan Name"
}
variable "appplan_kind" {
  type        = string
  description = "List of Plan Kinds"
  default     = "Linux"
}
variable "appplan_tags" {
  type        = map
  description = "collection of Tags"
  default     = {}
}
variable "appplan_sku" {
  type = object({
    tier = string
    size = string
  })
  description = "SKU Settings"
  default = {
    tier = "Standard"
    size = "S1"
  }
}
variable "app_subnet_name" {
  type        = string
  description = "subnet name"
  default     = ""
}
variable "app_subnet" {
  type        = string
  description = "Azure Application Subnet Address"
  default     = "10.1.2.0/24"
}
variable "webapp_name" {
  description = "Web App Name"
}
variable "webapp_app_settings" {
  type        = map
  description = "collection of App Settings"
  default     = {}
}
variable "webapp_site_config" {
  type = object({
    always_on                = bool
    dotnet_framework_version = string
    remote_debugging_enabled = bool
    linux_fx_version         = string
  })
  description = "Web App Site Config Settings"
  default = {
    always_on                = false
    dotnet_framework_version = "v2.0"
    remote_debugging_enabled = false
    linux_fx_version         = ""
  }
}
variable "webapp_https_only" {
  type        = bool
  description = "Force web app to HTTPS only"
  default     = false
}
variable "webapp_identity_type" {
  type        = string
  description = "Identity Type"
  default     = "SystemAssigned"
}