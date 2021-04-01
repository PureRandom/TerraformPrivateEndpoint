resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.subnet_address_prefixes
  dynamic "delegation" {
    for_each = var.subnet_delegation_name == "" ? [] : [1]
    content {
      name = var.subnet_delegation_name
      service_delegation {
        name    = var.subnet_delegation_type
        actions = var.subnet_delegation_actions
      }
    }
  }
  service_endpoints                              = var.subnet_service_endpoints
  enforce_private_link_endpoint_network_policies = var.subnet_enforce_private_link_endpoint_network_policies
}