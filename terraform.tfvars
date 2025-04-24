vnets_config = {
  vnet-hub = {
    location            = "eastus"
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"
    address_space       = ["10.0.0.0/16"]
    tags = {
      environment = "hub"
      project     = "networking"
    }
    subnets = {
      "GatewaySubnet" = {
        address_prefixes = ["10.0.0.0/24"]
        nsg_key          = "nsg-web"
        route_table_key  = "hub"
        tags = {
          role = "gateway"
        }
      }
      "AzureFirewallSubnet" = {
        address_prefixes = ["10.0.1.0/24"]
        nsg_key          = "nsg-bastion"
        route_table_key  = "spoke"
        tags = {
          role = "firewall"
        }
      }
    }
  }
  vnet-spoke = {
    location            = "eastus"
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"
    address_space       = ["10.1.0.0/16"]
    tags = {
      environment = "spoke"
      project     = "apps"
    }
    subnets = {

      "app" = {
        address_prefixes = ["10.1.1.0/24"]
        nsg_key          = "nsg-web"
        route_table_key  = "hub"
        tags = {
          app = "frontend"
        }
      }
      "db" = {
        address_prefixes = ["10.1.2.0/24"]
        nsg_key          = "nsg-bastion"
        route_table_key  = "spoke"
        tags = {
          app = "database"
        }
      }
    }
  }
}

peerings = {
  hub-to-spoke1 = {
    local_vnet_name         = "vnet-hub"
    remote_vnet_name        = "vnet-spoke"
    allow_forwarded_traffic = true
  }
  spoke-to-hub = {
    local_vnet_name     = "vnet-spoke"
    remote_vnet_name    = "vnet-hub"
    use_remote_gateways = true
  }
}

route_tables = {
  hub = {
    location            = "eastus"
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"
    tags = {
      env = "prod"
    }
    routes = {
      "to-internet" = {
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "Internet"
      },
      "to-nva" = {
        address_prefix         = "10.1.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.4"
      }
    }
  }
  spoke = {
    location            = "eastus"
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"
    tags = {
      env = "prod"
    }
    routes = {
      "to-hub" = {
        address_prefix = "10.0.0.0/16"
        next_hop_type  = "VirtualNetworkGateway"
      }
    }
  }
}

nsgs = {
  nsg-web = {
    location            = "eastus"
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"

    security_rules = {
      Allow-HTTP = {
        name                       = "Allow-HTTP"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
      Allow-HTTPS = {
        name                       = "Allow-HTTPS"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }
  nsg-bastion = {
    location            = "eastus"
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"

    security_rules = {
      Allow-SSH = {
        name                       = "Allow-SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
      Deny-All-Outbound = {
        name                       = "Deny-All-Outbound"
        priority                   = 200
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }
}

resource_groups = {
  "MF_MDIxMI_Github_PROD_RG" = {
    location = "eastus"
    tags = {
      environment = "core"
      team        = "network"
    }
  }
  "MF_MDIxMI_Github_PROD_RG1" = {
    location = "eastus"
    tags = {
      environment = "core"
      team        = "security"
    }
  }
  "MF_MDIxMI_Github_PROD_RG2" = {
    location = "westeurope"
    tags = {
      environment = "prod"
      team        = "apps"
    }
  }
}

keyvaults_config = {
  "kv-app1" = {
    location                  = "eastus"
    enable_rbac_authorization = true

    role_assignments = {
      "admin" = {
        role_definition_id_or_name = "Key Vault Administrator"
        principal_id               = "11111111-1111-1111-1111-111111111111"
      }
      "crypto_officer" = {
        role_definition_id_or_name = "Key Vault Crypto Officer"
        principal_id               = "22222222-2222-2222-2222-222222222222"
      }
    }

    access_policies = {
      "app-policy-1" = {
        tenant_id = "00000000-0000-0000-0000-000000000000"
        object_id = "aaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
        permissions = {
          keys         = ["Get", "List", "Decrypt"]
          secrets      = ["Get", "List"]
          certificates = []
          storage      = []
        }
      },
      "app-policy-2" = {
        tenant_id = "00000000-0000-0000-0000-000000000000"
        object_id = "bbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
        permissions = {
          keys         = ["Get"]
          secrets      = ["Get", "Set", "Delete"]
          certificates = ["Get"]
          storage      = []
        }
      }
    }

    tags = {
      env = "dev"
      app = "backend"
    }
  }

  "kv-app2" = {
    location                  = "westus2"
    enable_rbac_authorization = false

    role_assignments = {
      "reader" = {
        role_definition_id_or_name = "Key Vault Administrator"
        principal_id               = "ddddddd-dddd-dddd-dddd-dddddddddddd"
      }
    }

    access_policies = {
      "ops-policy" = {
        tenant_id = "00000000-0000-0000-0000-000000000000"
        object_id = "ccccccc-cccc-cccc-cccc-cccccccccccc"
        permissions = {
          keys         = ["List"]
          secrets      = ["List"]
          certificates = []
          storage      = []
        }
      }
    }

    tags = {
      env   = "prod"
      owner = "ops"
    }
  }
}

sqlmi_config = {
  primary = {
    name                         = "mf-dm-prod-sqlmi-primary"
    location                     = "eastus2"
    administrator_login          = "sqladmin"
    administrator_login_password = "YourSecurePassword123!"
    license_type                 = "LicenseIncluded"
    vnet_name                    = "vnet-spoke"
    subnets = {
      db = "subnet-db"
      # redis = "subnet-redis"
    }
    sku_name            = "GP_Gen5"
    vcores              = 8
    storage_size_in_gb  = 32
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"

    managed_identities = {
      system_assigned = true
      user_assigned   = []
    }
  }
  secondary = {
    name                         = "mf-dm-prod-sqlmi-secondary"
    location                     = "eastus2"
    administrator_login          = "sqladmin"
    administrator_login_password = "YourSecurePassword123!"
    license_type                 = "LicenseIncluded"
    vnet_name                    = "vnet-hub"
    subnets = {
      db = "subnet-db"
      # redis = "subnet-redis"
    }
    sku_name            = "GP_Gen5"
    vcores              = 8
    storage_size_in_gb  = 32
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"

    managed_identities = {
      system_assigned = true
      user_assigned   = []
    }
  }
}

# acr_config = {
#   name                    = "myacr"
#   resource_group_name     = "MF_MDIxMI_Github_PROD_RG"
#   location                = "eastus"
#   sku                     = "Premium"
#   admin_enabled           = false
#   # zone_redundancy_enabled = true

#   georeplications = [
#     {
#       location                = "Central India"
#       # zone_redundancy_enabled = true
#     },
#     {
#       location                = "Canada Central"
#       # zone_redundancy_enabled = true
#     }
#   ]

#   tags = {
#     environment = "prod"
#     team        = "devops"
#   }
# }





