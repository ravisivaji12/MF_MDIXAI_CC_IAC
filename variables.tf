variable "vnets_config" {
  description = "Map of VNets with subnet configurations"
  type = map(object({
    location            = string
    resource_group_name = string
    address_space       = list(string)
    tags                = map(string)
    subnets = map(object({
      address_prefixes = list(string)
      nsg_key          = string
      route_table_key  = string
      tags             = map(string)
    }))
  }))
}
variable "route_tables" {
  description = "Map of route tables, each with location, RG, tags, and route definitions"
  type = map(object({
    location            = string
    resource_group_name = string
    tags                = map(string)
    routes = map(object({
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    }))
  }))
}
variable "nsgs" {
  description = "Map of Network Security Groups with their properties and rules"
  type = map(object({
    location            = string
    resource_group_name = string
    security_rules = map(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
}

variable "resource_groups" {
  description = "Map of resource groups to create"
  type = map(object({
    location = string
    tags     = map(string)
  }))
}
variable "peerings" {
  description = "Map of virtual network peerings"
  type = map(object({
    local_vnet_name              = string
    remote_vnet_name             = string
    allow_forwarded_traffic      = optional(bool, false)
    allow_gateway_transit        = optional(bool, false)
    allow_virtual_network_access = optional(bool, true)
    use_remote_gateways          = optional(bool, false)
    # create_reverse_peering                 = optional(bool, true)
    # reverse_allow_forwarded_traffic        = optional(bool, false)
    # reverse_allow_gateway_transit          = optional(bool, false)
    # reverse_allow_virtual_network_access   = optional(bool, true)
    # reverse_use_remote_gateways            = optional(bool, false)
  }))
}

variable "keyvaults_config" {
  description = "Config for multiple key vaults with access policies and role assignments"
  type = map(object({
    location                  = string
    enable_rbac_authorization = bool

    access_policies = optional(map(object({
      tenant_id      = string
      object_id      = string
      application_id = optional(string)
      permissions = object({
        keys         = list(string)
        secrets      = list(string)
        certificates = list(string)
        storage      = list(string)
      })
    })))

    role_assignments = optional(map(object({
      role_definition_id_or_name = string
      principal_id               = string
    })))

    tags = map(string)
  }))
}


# resource "azurerm_key_vault" "MF_MDI_CC_CORE-KEY-VAULT" {
#   name                            = var.cc_core_key_vault
#   location                        = azurerm_resource_group.MF_MDI_CC-RG.location
#   resource_group_name             = azurerm_resource_group.MF_MDI_CC-RG.name
#   enabled_for_disk_encryption     = true
#   tenant_id                       = data.azurerm_client_config.current.tenant_id
#   soft_delete_retention_days      = 7
#   purge_protection_enabled        = false
#   enabled_for_template_deployment = true
#   sku_name                        = var.cc_core_key_vault_sku

# }
# resource "azurerm_key_vault_access_policy" "TERRAFORM_USER_KV_ACCESS_POLICY" {

#   key_vault_id = azurerm_key_vault.MF_MDI_CC_CORE-KEY-VAULT.id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   object_id    = data.azurerm_client_config.current.object_id
#   certificate_permissions = [
#     "Get", "List", "Create", "Update", "Delete", "GetIssuers", "Import", "ListIssuers", "SetIssuers", "ManageIssuers", "ManageContacts"
#   ]
#   secret_permissions = [
#     "Set", "Get", "Delete", "Purge", "Recover", "List"
#   ]
#   key_permissions = [
#     "Get", "List", "Import", "Create", "Update", "Delete", "Recover"
#   ]
#   depends_on = [
#     azurerm_key_vault.MF_MDI_CC_CORE-KEY-VAULT
#   ]
#   lifecycle {
#     prevent_destroy = false
#   }
# }
