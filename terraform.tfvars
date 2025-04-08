cc_location                    = "Canada Central"
cc_core_resource_group_name    = "MF_MDIxMI_Github_PROD_RG"
cc_storage_resource_group_name = "MF_MDI_CC_GH_STORAGE-PROD-RG"

kv_name                         = "MF-MDI-CORE-PRD-GH-KV"
sku_name                        = "standard"
soft_delete_retention_days      = 7
purge_protection_enabled        = false
public_network_access_enabled   = true
enabled_for_deployment          = true
enabled_for_disk_encryption     = true
enabled_for_template_deployment = true
enable_rbac_authorization       = true


##################VNET & SUBNET###########################################
cc_vnet = {
  vnet1 = {
    name                = "MF_MDI_CC_PROD_CORE-VNET"
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"
    location            = "canadacentral"
    address_space       = ["10.125.176.0/21"]
    subnets = {
      subnet1 = {
        name                              = "MF_MDI_CC_PERF_SQLMI-SNET"
        address_prefixes                  = ["10.125.181.192/27"]
        service_endpoints                 = []
        nsg_name                          = "MF_MDI_CC_SQLMI-NSG"
        private_endpoint_network_policies = "Disabled"
        delegation = [{
          name = "sqlMI"
          service_delegation = {
            name    = "Microsoft.Sql/managedInstances"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
          }
        }]
        tags = {
          "Application Name" = "McCain DevSecOps"
          "GL Code"          = "N/A"
          "Environment"      = "sandbox"
          "IT Owner"         = "mccain-azurecontributor@mccain.ca"
          "Onboard Date"     = "12/19/2024"
          "Modified Date"    = "N/A"
          "Organization"     = "McCain Foods Limited"
          "Business Owner"   = "ravi.sivaji@mccain.ca"
          "Implemented by"   = "ravi.sivaji@mccain.ca"
          "Resource Owner"   = "ravi.sivaji@mccain.ca"
          "Resource Posture" = "Private"
          "Resource Type"    = "Terraform POC"
          "Built Using"      = "Terraform"
        }
      }
      subnet2 = {
        name                              = "MF_MDI_CC_CAPPS-SNET"
        address_prefixes                  = ["10.125.176.0/23"]
        nsg_name                          = "MF_MDI_CC_CAPPS-NSG"
        service_endpoints                 = []
        delegation                        = []
        private_endpoint_network_policies = "Disabled"
        tags = {
          "Application Name" = "McCain DevSecOps"
          "GL Code"          = "N/A"
          "Environment"      = "sandbox"
          "IT Owner"         = "mccain-azurecontributor@mccain.ca"
          "Onboard Date"     = "12/19/2024"
          "Modified Date"    = "N/A"
          "Organization"     = "McCain Foods Limited"
          "Business Owner"   = "ravi.sivaji@mccain.ca"
          "Implemented by"   = "ravi.sivaji@mccain.ca"
          "Resource Owner"   = "ravi.sivaji@mccain.ca"
          "Resource Posture" = "Private"
          "Resource Type"    = "Terraform POC"
          "Built Using"      = "Terraform"
        }
      }
      subnet3 = {
        name                              = "MF_MDI_CC_AFUNC-SNET"
        private_endpoint_network_policies = "Disabled"
        address_prefixes                  = ["10.125.178.0/24"]
        service_endpoints                 = []
        delegation = [{
          name = "Microsoft.Web/serverFarms"
          service_delegation = {
            name    = "Microsoft.Web/serverFarms"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action", ]
          }
        }]
        tags = {
          "Application Name" = "McCain DevSecOps"
          "GL Code"          = "N/A"
          "Environment"      = "sandbox"
          "IT Owner"         = "mccain-azurecontributor@mccain.ca"
          "Onboard Date"     = "12/19/2024"
          "Modified Date"    = "N/A"
          "Organization"     = "McCain Foods Limited"
          "Business Owner"   = "ravi.sivaji@mccain.ca"
          "Implemented by"   = "ravi.sivaji@mccain.ca"
          "Resource Owner"   = "ravi.sivaji@mccain.ca"
          "Resource Posture" = "Private"
          "Resource Type"    = "Terraform POC"
          "Built Using"      = "Terraform"
        }
      }
      subnet4 = {

        name                              = "MF_MDI_CC_PLINK-SNET"
        address_prefixes                  = ["10.125.181.0/26"]
        service_endpoints                 = []
        delegation                        = []
        private_endpoint_network_policies = "Disabled"
        tags = {
          "Application Name" = "McCain DevSecOps"
          "GL Code"          = "N/A"
          "Environment"      = "sandbox"
          "IT Owner"         = "mccain-azurecontributor@mccain.ca"
          "Onboard Date"     = "12/19/2024"
          "Modified Date"    = "N/A"
          "Organization"     = "McCain Foods Limited"
          "Business Owner"   = "ravi.sivaji@mccain.ca"
          "Implemented by"   = "ravi.sivaji@mccain.ca"
          "Resource Owner"   = "ravi.sivaji@mccain.ca"
          "Resource Posture" = "Private"
          "Resource Type"    = "Terraform POC"
          "Built Using"      = "Terraform"
        }
      }
      subnet5 = {
        name                              = "MF_MDI_CC_VMSS-SNET"
        address_prefixes                  = ["10.125.181.224/27"]
        service_endpoints                 = []
        delegation                        = []
        private_endpoint_network_policies = "Disabled"
        delegation = [{
          name = "Microsoft.StreamAnalytics.streamingJobs"
          service_delegation = {
            name    = "Microsoft.StreamAnalytics/streamingJobs"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", ]
          }
        }]
        tags = {
          "Application Name" = "McCain DevSecOps"
          "GL Code"          = "N/A"
          "Environment"      = "sandbox"
          "IT Owner"         = "mccain-azurecontributor@mccain.ca"
          "Onboard Date"     = "12/19/2024"
          "Modified Date"    = "N/A"
          "Organization"     = "McCain Foods Limited"
          "Business Owner"   = "ravi.sivaji@mccain.ca"
          "Implemented by"   = "ravi.sivaji@mccain.ca"
          "Resource Owner"   = "ravi.sivaji@mccain.ca"
          "Resource Posture" = "Private"
          "Resource Type"    = "Terraform POC"
          "Built Using"      = "Terraform"
        }
      }
  } }
  vnet2 = {
    name                = "MF_MDI_CC_PROD_API-VNET"
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"
    location            = "canadacentral"
    address_space       = ["10.125.176.0/21"]
    subnets = {
      s1 = {
        name                              = "MF_MDI_CC_APIM-SNET"
        address_prefixes                  = ["10.125.187.64/26"]
        nsg_name                          = "MF_MDI_CC_APIM-NSG"
        service_endpoints                 = ["Microsoft.AzureCosmosDB", "Microsoft.Storage"]
        delegation                        = []
        private_endpoint_network_policies = "Disabled"
        tags = {
          "Application Name" = "McCain DevSecOps"
          "GL Code"          = "N/A"
          "Environment"      = "sandbox"
          "IT Owner"         = "mccain-azurecontributor@mccain.ca"
          "Onboard Date"     = "12/19/2024"
          "Modified Date"    = "N/A"
          "Organization"     = "McCain Foods Limited"
          "Business Owner"   = "ravi.sivaji@mccain.ca"
          "Implemented by"   = "ravi.sivaji@mccain.ca"
          "Resource Owner"   = "ravi.sivaji@mccain.ca"
          "Resource Posture" = "Private"
          "Resource Type"    = "Terraform POC"
          "Built Using"      = "Terraform"
        }
      }
      s2 = {
        name                              = "MF_MDI_CC_APPGW-SNET"
        address_prefixes                  = ["10.125.187.0/26"]
        private_endpoint_network_policies = "Enabled"
        service_endpoints                 = []
        delegation                        = []
        tags = {
          "Application Name" = "McCain DevSecOps"
          "GL Code"          = "N/A"
          "Environment"      = "sandbox"
          "IT Owner"         = "mccain-azurecontributor@mccain.ca"
          "Onboard Date"     = "12/19/2024"
          "Modified Date"    = "N/A"
          "Organization"     = "McCain Foods Limited"
          "Business Owner"   = "ravi.sivaji@mccain.ca"
          "Implemented by"   = "ravi.sivaji@mccain.ca"
          "Resource Owner"   = "ravi.sivaji@mccain.ca"
          "Resource Posture" = "Private"
          "Resource Type"    = "Terraform POC"
          "Built Using"      = "Terraform"
        }
      }
    }
  }
}