terraform {
  required_version = ">= 1.4.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.76.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "abd34832-7708-43f9-a480-e3b7a87b41d7"
}

module "resource_groups" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  for_each = var.resource_groups

  name     = each.key
  location = each.value.location
  tags     = each.value.tags
}

module "routetables" {
  for_each = var.route_tables

  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.4.1"

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = each.value.tags

  routes = {
    for route_name, route_config in each.value.routes : route_name => {
      name                   = route_name
      address_prefix         = route_config.address_prefix
      next_hop_type          = route_config.next_hop_type
      next_hop_in_ip_address = route_config.next_hop_in_ip_address
    }
  }

  depends_on = [module.resource_groups]
}

module "nsgs" {
  source   = "Azure/avm-res-network-networksecuritygroup/azurerm"
  for_each = var.nsgs

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  security_rules = each.value.security_rules
  depends_on     = [module.resource_groups]
}


module "vnets" {
  for_each = var.vnets_config

  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.8.1"

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
  tags                = each.value.tags

  subnets = {
    for subnet_name, subnet_config in each.value.subnets : subnet_name => {
      name             = subnet_name
      address_prefixes = subnet_config.address_prefixes
      nsg_id           = module.nsgs[subnet_config.nsg_key].resource_id
      route_table_id   = module.routetables[subnet_config.route_table_key].resource_id
      # private_endpoint_network_policies = "Enabled"
      # service_endpoints = subnet_config.service_endpoints
      # delegation = [ {
      #   name = subnet_config.delegation_name
      #   service_delegation = {
      #     name    = subnet_config.service_delegation_name
      #     actions = subnet_config.actions
      #   }
      # } ]
      tags = subnet_config.tags
    }
  }
  depends_on = [module.resource_groups, module.nsgs, module.routetables]
}

resource "azurerm_virtual_network_peering" "peerings" {
  for_each = var.peerings

  name                      = "${each.key}-peering"
  resource_group_name       = "MF_MDIxMI_Github_PROD_RG" #module.vnets[each.value.local_vnet_name].resource.resource_group.name
  virtual_network_name      = module.vnets[each.value.local_vnet_name].name
  remote_virtual_network_id = module.vnets[each.value.remote_vnet_name].resource_id

  allow_forwarded_traffic      = try(each.value.allow_forwarded_traffic, false)
  allow_gateway_transit        = try(each.value.allow_gateway_transit, false)
  allow_virtual_network_access = try(each.value.allow_virtual_network_access, true)
  use_remote_gateways          = try(each.value.use_remote_gateways, false)

  depends_on = [module.vnets]
}

module "keyvaults" {
  for_each = var.keyvaults_config

  source = "Azure/avm-res-keyvault-vault/azurerm"
  # version = "x.y.z"

  name                = each.key
  location            = each.value.location
  resource_group_name = "MF_MDIxMI_Github_PROD_RG"
  tenant_id           = "fd036ad5-08f1-4dab-947b-3b6f9462e84d" #var.tenant_id
  #enable_rbac_authorization   = each.value.enable_rbac_authorization

  #access_policies             = lookup(each.value, "access_policies", [])
  legacy_access_policies_enabled = true
  legacy_access_policies         = lookup(each.value, "legacy_access_policies", {})
  role_assignments               = lookup(each.value, "role_assignments", {})

  tags = each.value.tags
}


# module "avm-res-sql-managedinstance" {
#   source  = "Azure/avm-res-sql-managedinstance/azurerm"
#   version = "0.1.0"
#   # insert the 10 required variables here
# }



# Module for Azure Container App Environment and Azure Container Apps
# resource "azurerm_container_registry" "MF_MDI_CC_CORE_ACR" {
#   name                = var.cc_core_acr_name
#   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
#   location            = azurerm_resource_group.MF_MDI_CC-RG.location
#   sku                 = var.cc_core_acr_sku
#   admin_enabled       = true
#   tags                = local.tag_list_1
# }

