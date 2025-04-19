output "network_tags_summary" {
  description = "Combined VNet and subnet tag mapping"
  value = {
    vnet_tags = {
      for vnet_name, vnet in var.vnets_config :
      vnet_name => vnet.tags
    }
    subnet_tags = {
      for vnet_name, vnet in var.vnets_config :
      vnet_name => {
        for subnet_name, subnet in vnet.subnets :
        subnet_name => subnet.tags
      }
    }
  }
}
output "vnet_names" {
  description = "values of vnet names"
  value       = [for vnet_name, _ in var.vnets_config : vnet_name]
}
output "subnet_names" {
  description = "values of subnet names"
  value       = flatten([for vnet_name, vnet in var.vnets_config : [for subnet_name, _ in vnet.subnets : "${vnet_name}/${subnet_name}"]])
}

output "route_table_ids" {
  value = {
    for k, m in module.routetables : k => m.resource.id
  }
}
output "route_table_names" {
  value = {
    for k, m in module.routetables : k => m.resource.name
  }
}
output "route_table_resources" {
  value = {
    for k, m in module.routetables : k => m.resource
  }
}
output "nsg_ids" {
  value = {
    for nsg_key, nsg in module.nsgs : nsg_key => nsg.resource_id
  }
}

output "resource_group_names" {
  value = [for rg in module.resource_groups : rg.name]
}

output "resource_group_ids" {
  value = [for rg in module.resource_groups : rg.resource_id]
}

output "keyvault_names" {
  description = "Key Vault names"
  value = {
    for k, v in module.keyvaults : k => v.name
  }
}

output "keyvault_ids" {
  description = "Key Vault resource IDs"
  value = {
    for k, v in module.keyvaults : k => v.resource_id
  }
}

output "keyvault_uris" {
  description = "Key Vault DNS URIs"
  value = {
    for k, v in module.keyvaults : k => v.uri
  }
}

output "keyvault_access_policies" {
  description = "Access policies applied to each Key Vault"
  value = {
    for k, v in module.keyvaults : k => try(v.access_policies, {})
  }
}

output "keyvault_role_assignments" {
  description = "Role assignments for each Key Vault"
  value = {
    for k, v in module.keyvaults : k => try(v.role_assignments, {})
  }
}


