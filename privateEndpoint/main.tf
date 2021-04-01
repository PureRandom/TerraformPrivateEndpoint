# Create a DB Private DNS Zone
resource "azurerm_private_dns_zone" "private-endpoint-dns-private-zone" {
  name                = var.dnszone_private_link
  resource_group_name = var.resource_group_name
}

# Create Private Endpoint
resource "azurerm_private_endpoint" "private-endpoint" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  dynamic "private_service_connection" {
    for_each = var.private_endpoint_service_connections
    content {
      name                           = private_service_connection.value["name"]
      private_connection_resource_id = private_service_connection.value["private_connection_resource_id"]
      subresource_names              = private_service_connection.value["subresource_names"]
      is_manual_connection           = private_service_connection.value["is_manual_connection"]
    }
  }
  private_dns_zone_group {
    name = replace(var.dnszone_private_link, ".", "_")
    private_dns_zone_ids = [
      azurerm_private_dns_zone.private-endpoint-dns-private-zone.id
    ]
  }
  depends_on = [
    azurerm_private_dns_zone.private-endpoint-dns-private-zone
  ]
}

# DB Private Endpoint Connecton
data "azurerm_private_endpoint_connection" "private-endpoint-connection" {
  name                = azurerm_private_endpoint.private-endpoint.name
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_private_endpoint.private-endpoint
  ]
}

# Create a Private DNS to VNET link
resource "azurerm_private_dns_zone_virtual_network_link" "dns-zone-to-vnet-link" {
  name                  = "${var.resource_name}-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private-endpoint-dns-private-zone.name
  virtual_network_id    = var.vnet_id
}
