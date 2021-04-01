variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group"
}
variable "location" {
  type        = string
  description = "Location of resource"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
}
variable "subnet_name" {
  type        = string
  description = "Name of the Subnet"
}
variable "subnet_address_prefixes" {
  type        = list(string)
  description = "Subnet Address Prefixes"
  default     = ["10.0.1.0/24"]
}
variable "subnet_delegation_name" {
  type        = string
  description = "Name of Subnet Delegation"
  default     = ""
}
variable "subnet_delegation_type" {
  type        = string
  description = "Name of Subnet Delegation Type"
  default     = null
}
variable "subnet_delegation_actions" {
  type        = list(string)
  description = "Name of Subnet Delegation Actions"
  default     = null
}
variable "subnet_service_endpoints" {
  type        = list(string)
  description = "Name of Subnet Service Endpoints"
  default     = null
}
variable "subnet_enforce_private_link_endpoint_network_policies" {
  type        = bool
  description = "Enforce the Private Link endpoint"
  default     = false
}