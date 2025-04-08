#### RG############
variable "cc_location" {
  type        = string
  description = "Canada Central Region"
}

variable "cc_core_resource_group_name" {
  type        = string
  description = "Resource Group Name for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"
}

variable "cc_storage_resource_group_name" {
  type        = string
  default     = "MF_MDI_CC_GH_STORAGE-PROD-RG"
  description = "Resource Group Name for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"
}

##KV#####
variable "kv_name" {
  description = "The name of the resource."
  type        = string
}
variable "sku_name" {
  description = "The SKU name for the resource."
  type        = string
}
variable "soft_delete_retention_days" {
  description = "The retention period for soft delete in days."
  type        = number
}
variable "purge_protection_enabled" {
  description = "Enable purge protection for the resource."
  type        = bool
}

variable "public_network_access_enabled" {
  description = "Enable public network access to the resource."
  type        = bool
}

variable "enable_rbac_authorization" {
  description = "Enable RBAC authorization for the resource."
  type        = bool
}

variable "enabled_for_deployment" {
  description = "Indicates whether the resource is enabled for deployment."
  type        = bool
}

variable "enabled_for_disk_encryption" {
  description = "Indicates whether the resource is enabled for disk encryption."
  type        = bool
}

variable "enabled_for_template_deployment" {
  description = "Indicates whether the resource is enabled for template deployment."
  type        = bool
}

variable "cc_vnet" {
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    address_space       = list(string)
    subnets = map(object({
      name                              = string
      address_prefixes                  = list(string)
      service_endpoints                 = list(string)
      private_endpoint_network_policies = string
      delegation = list(object({
        name = string
        service_delegation = object({
          name = string
        actions = list(string) })
      }))
    }))
  }))
  description = "Map of virtual networks"
}