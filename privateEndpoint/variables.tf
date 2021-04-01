variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}
variable "location" {
  type        = string
  description = "Resource Location"
}
variable "private_endpoint_name" {
  type        = string
  description = "Private Endpoint Name"
}
variable "private_endpoint_service_connections" {
  type = list(object({
    name                           = string
    private_connection_resource_id = string
    subresource_names              = list(string)
    is_manual_connection           = bool
  }))
  description = "List of Private Endpoint Service Connections"
  default     = []
}
variable "vnet_id" {
  type        = string
  description = "VNet ID"
}
variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}
variable "resource_name" {
  type        = string
  description = "Name of resource Private Endpoint is for"
}
variable "dnszone_private_link" {
  type        = string
  description = "Validate Private Link URL https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns"
}
