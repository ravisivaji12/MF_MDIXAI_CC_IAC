data "azurerm_client_config" "current" {}
# module "MC_KEYVAULT" {
#   source  = "app.terraform.io/Mccain_Foods/sample/azurerm"
#   version = "0.0.3"
#   name                            = var.kv_name
#   location                        = var.cc_location
#   resource_group_name             = var.cc_core_resource_group_name
#   sku_name                        = var.sku_name
#   tenant_id                       = data.azurerm_client_config.current.tenant_id
#   soft_delete_retention_days      = var.soft_delete_retention_days
#   purge_protection_enabled        = var.purge_protection_enabled
#   enable_rbac_authorization       = var.enable_rbac_authorization
#   enabled_for_deployment          = var.enabled_for_deployment
#   enabled_for_disk_encryption     = var.enabled_for_disk_encryption
#   enabled_for_template_deployment = var.enabled_for_template_deployment
#   env                             = "SANDBOX"
# }