module "MF_MDI_CC-RG" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  name     = var.cc_core_resource_group_name
  location = var.cc_location
  tags     = local.tag_list_1
}

module "MF_MDI_CC_STORAGE-RG" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  name     = var.cc_storage_resource_group_name
  location = var.cc_location
  tags     = local.tag_list_1
}