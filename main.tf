## GENERAL ##
provider "azurerm" {
  version = "=2.25.0"
  features {}
}
provider "random" {
  version = ">= 2.2.0"
}
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

## VNET ##
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.1.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}



## MYSQL ##
resource "random_password" "password" {
  length      = 20
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
}
resource "azurerm_mysql_server" "mysql_server" {
  name                              = var.mysql_server_name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  administrator_login               = var.mysql_server_username
  administrator_login_password      = var.mysql_server_password == "" ? random_password.password.result : var.mysql_server_password
  sku_name                          = var.mysql_server_sku
  storage_mb                        = var.mysql_server_storage
  version                           = var.mysql_server_version
  auto_grow_enabled                 = var.mysql_server_settings.auto_grow_enabled
  backup_retention_days             = var.mysql_server_settings.backup_retention_days
  geo_redundant_backup_enabled      = var.mysql_server_settings.geo_redundant_backup_enabled
  infrastructure_encryption_enabled = var.mysql_server_settings.infrastructure_encryption_enabled
  public_network_access_enabled     = var.mysql_server_settings.public_network_access_enabled
  ssl_enforcement_enabled           = var.mysql_server_settings.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced  = var.mysql_server_settings.ssl_minimal_tls_version_enforced
}

module "private-endpoint-subnet" {
  source                                                = "./subnet"
  resource_group_name                                   = var.resource_group_name
  location                                              = var.location
  vnet_name                                             = azurerm_virtual_network.vnet.name
  subnet_name                                           = local.private_endpoint_subnet_name
  subnet_address_prefixes                               = [var.private_endpoint_subnet]
  subnet_enforce_private_link_endpoint_network_policies = true
  depends_on = [
    azurerm_mysql_server.mysql_server
  ]
}
module "private-endpoint" {
  source                = "./privateEndpoint"
  resource_group_name   = var.resource_group_name
  location              = var.location
  private_endpoint_name = var.mysql_server_private_endpoint
  private_endpoint_service_connections = [
    {
      name                           = "${var.mysql_server_name}.privateEndpoint"
      private_connection_resource_id = azurerm_mysql_server.mysql_server.id
      subresource_names              = ["mysqlServer"]
      is_manual_connection           = false
    }
  ]
  vnet_id              = azurerm_virtual_network.vnet.id
  subnet_id            = module.private-endpoint-subnet.subnet_id
  resource_name        = var.mysql_server_name
  dnszone_private_link = "privatelink.mysql.database.azure.com"
}


## APP SERVICE ##
module "application-subnet" {
  source                    = "./subnet"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  vnet_name                 = azurerm_virtual_network.vnet.name
  subnet_name               = var.app_subnet_name
  subnet_address_prefixes   = [var.app_subnet]
  subnet_delegation_name    = "app-service-delegation"
  subnet_delegation_type    = "Microsoft.Web/serverFarms"
  subnet_delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
  subnet_service_endpoints  = ["Microsoft.Web"]

  depends_on = [
    azurerm_mysql_server.mysql_server,
    azurerm_virtual_network.vnet,
    module.private-endpoint
  ]
}
resource "azurerm_app_service_plan" "app_plan" {
  name                = var.appplan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = var.appplan_kind
  reserved            = true
  sku {
    tier = var.appplan_sku.tier
    size = var.appplan_sku.size
  }
}
locals {
  app_settings_subnet = {
    WEBSITE_VNET_ROUTE_ALL = 1
    WEBSITE_DNS_SERVER     = "168.63.129.16"
  }
  app_settings = merge(var.webapp_app_settings, local.app_settings_subnet)
}
resource "azurerm_app_service" "web_app" {
  name                = var.webapp_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = var.appplan_name
  app_settings        = local.app_settings

  site_config {
    always_on                = var.webapp_site_config.always_on
    dotnet_framework_version = var.webapp_site_config.dotnet_framework_version
    remote_debugging_enabled = var.webapp_site_config.remote_debugging_enabled
    linux_fx_version         = var.webapp_site_config.linux_fx_version
  }
  identity {
    type = var.webapp_identity_type
  }

}

