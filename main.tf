# terraform {
#   required_version = ">= 1.4.0"

#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = ">= 3.76.0"
#     }
#   }
# }

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

# data "azurerm_subnet" "target" {
#   name                 = "db"
#   virtual_network_name = "vnet-spoke"
#   resource_group_name  = var.sqlmi_config.resource_group_name
#   depends_on           = [module.vnets]
# }

data "azurerm_subnet" "all" {
  for_each = {
    for subnet in flatten([
      for env_key, env_val in var.sqlmi_config : [
        for subnet_key, subnet_name in env_val.subnets : {
          key                  = "${env_key}.${subnet_key}"
          name                 = subnet_name
          virtual_network_name = env_val.vnet_name
          resource_group_name  = env_val.resource_group_name
        }
      ]
      ]) : subnet.key => {
      name                 = subnet.name
      virtual_network_name = subnet.virtual_network_name
      resource_group_name  = subnet.resource_group_name
    }
  }
  name                 = each.value.name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
  depends_on           = [module.vnets]
}

module "sqlmi_primary" {
  source                       = "Azure/avm-res-sql-managedinstance/azurerm"
  version                      = "0.1.0"
  name                         = var.sqlmi_config["primary"].name
  location                     = var.sqlmi_config["primary"].location
  administrator_login          = var.sqlmi_config["primary"].administrator_login
  administrator_login_password = var.sqlmi_config["primary"].administrator_login_password
  license_type                 = var.sqlmi_config["primary"].license_type
  subnet_id                    = data.azurerm_subnet.all["primary.db"].id
  sku_name                     = var.sqlmi_config["primary"].sku_name
  vcores                       = var.sqlmi_config["primary"].vcores
  storage_size_in_gb           = var.sqlmi_config["primary"].storage_size_in_gb
  resource_group_name          = var.sqlmi_config["primary"].resource_group_name
  managed_identities           = var.sqlmi_config["primary"].managed_identities != null ? var.sqlmi_config["primary"].managed_identities : null
  # Unexpected attribute: An attribute named "backup_storage_redundancy" is not supported in this avm module. 
  # AVM module has to downloaded and modified accordingly to configure automated backups using this AVM module.
  # backup_storage_redundancy    = "Geo"
  maintenance_configuration_name = "SQL_Default"
  minimum_tls_version            = "1.2"
  public_data_endpoint_enabled   = false

  # failover_group is not supported in SQLMI AVM module
  # failover_group = {
  #   location = var.sqlmi_config.location
  #   name = "sqlmi_failovergrp"
  #   partner_managed_instance_id = azurerm_mssql_managed_instance.sqlmi_secondary.id
  # }

  depends_on = [module.resource_groups, module.vnets, module.nsgs, module.routetables, module.keyvaults]
}

module "sqlmi_secondary" {
  source                         = "Azure/avm-res-sql-managedinstance/azurerm"
  name                           = var.sqlmi_config["secondary"].name
  location                       = var.sqlmi_config["secondary"].location
  administrator_login            = var.sqlmi_config["secondary"].administrator_login
  administrator_login_password   = var.sqlmi_config["secondary"].administrator_login_password
  license_type                   = var.sqlmi_config["secondary"].license_type
  subnet_id                      = data.azurerm_subnet.all["secondary.db"].id
  sku_name                       = var.sqlmi_config["secondary"].sku_name
  vcores                         = var.sqlmi_config["secondary"].vcores
  storage_size_in_gb             = var.sqlmi_config["secondary"].storage_size_in_gb
  resource_group_name            = var.sqlmi_config["secondary"].resource_group_name
  managed_identities             = var.sqlmi_config["secondary"].managed_identities != null ? var.sqlmi_config["secondary"].managed_identities : null
  maintenance_configuration_name = "SQL_Default"
  minimum_tls_version            = "1.2"
  public_data_endpoint_enabled   = false

  depends_on = [module.resource_groups, module.vnets, module.nsgs, module.routetables, module.keyvaults]
}

resource "azurerm_mssql_managed_instance_failover_group" "fog" {
  name                        = "sqlmi-fog"
  location                    = var.sqlmi_config["primary"].location
  managed_instance_id         = module.sqlmi_primary.resource_id
  partner_managed_instance_id = module.sqlmi_secondary.resource_id

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
}

# Azure Container Registry Module
module "avm-res-containerregistry" {
  source              = "Azure/avm-res-containerregistry-registry/azurerm//examples/geo-replication"
  version             = "0.4.0"
  admin_enabled = true
  name = "my-ACR"
  location = "eastus"
  sku = "Premium"
   resource_group_name = "MF_MDIxMI_Github_PROD_RG"
   zone_redundancy_enabled = true
   georeplications = [
    {
      location = "Canada Central"
    },
    {
      location = "Central India"
    }
  ]
}

# module "avm-res-containerregistry-registry_example_geo-replication" {
#   source              = "Azure/avm-res-containerregistry-registry/azurerm//examples/geo-replication"
#   version             = "0.4.0"
#   name                = var.acr_config.name                # var.cc_core_acr_name
#   resource_group_name = var.acr_config.resource_group_name #azurerm_resource_group.MF_MDI_CC-RG.name
#   location            = var.acr_config.location            #azurerm_resource_group.MF_MDI_CC-RG.location
#   # sku                 = var.acr_config.sku                 # var.cc_core_acr_sku
#   # admin_enabled       = var.acr_config.admin_enabled
#   # tags                = local.tag_list_1

#   # zone_redundancy_enabled must be supported in the region. Not all Azure regions support AZs. If unsupported in a region, enabling it will result in an error. 
#   # Requires Premium SKU. You can set it per geo-replication region as well.
#   # Best Practices: Use zone-redundant ACR, Integrate with Private Endpoints and Use RBAC and diagnostics logging for security and audit

#   # zone_redundancy_enabled = var.acr_config.zone_redundancy_enabled
#   georeplications         = var.acr_config.georeplications

#   # georeplications = [
#   #   {
#   #     location = "Canada Central"
#   #     # zone redundancy is enabled by default, and is supported in australia east
#   #     tags = {
#   #       environment = "prod"
#   #       department  = "engineering"
#   #     }
#   #   },
#   #   {
#   #     location                = "Central India"
#   #     # zone_redundancy_enabled = var.acr_config.zone_redundancy_enabled
#   #     tags = {
#   #       environment = "prod"
#   #       department  = "engineering"
#   #     }
#   #   }
#   # ]

#   tags = var.acr_config.tags

#   #  The module at module.avm-res-containerregistry-registry_example_geo-replication is a legacy module which contains its own local provider configurations, 
#   # and so calls to it may not use the count, for_each, or depends_on arguments.

#   # depends_on = [ module.resource_groups, module.vnets, module.nsgs, module.routetables ] 

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

