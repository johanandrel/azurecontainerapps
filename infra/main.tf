resource "azurerm_resource_group" "container_apps_poc" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags     = var.resource_group_tags
}

# User assigned managed identity does not require elevated rights in Entra upon creation
resource "azurerm_user_assigned_identity" "github_identity" {
  location            = azurerm_resource_group.container_apps_poc.location
  name                = var.github_user_assigned_identity_name
  resource_group_name = azurerm_resource_group.container_apps_poc.name
}

# Role based access control to allow managed identity to push images to ACR
resource "azurerm_role_assignment" "acrpushprod" {
  scope                = azurerm_resource_group.container_apps_poc.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.github_identity.principal_id
}

# Federation thats allows managed identity to be used on main branch (GitHub Actions)
resource "azurerm_federated_identity_credential" "github_identity_federated_main" {
  name                = "${azurerm_user_assigned_identity.github_identity.name}federatedmain"
  resource_group_name = azurerm_resource_group.container_apps_poc.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.github_identity.id
  subject             = "repo:${var.github_repo}:ref:refs/heads/main"
}

# Federation thats allows managed identity to be used on feature branches (GitHub Actions)
resource "azurerm_federated_identity_credential" "github_identity_federated_pr" {
  name                = "${azurerm_user_assigned_identity.github_identity.name}federatedpr"
  resource_group_name = azurerm_resource_group.container_apps_poc.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.github_identity.id
  subject             = "repo:${var.github_repo}:pull_request"
}

# Container Registry that will manage containers that will be deployed
resource "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.container_apps_poc.name
  location            = azurerm_resource_group.container_apps_poc.location
  admin_enabled       = false     # Default, rather use managed identity and role based access control 
  sku                 = "Premium" # Note that Premium is required to use Private Endpoints, otherwise Basic can be used for testing purposes
  identity {
    type = "SystemAssigned"
  }
}

# User assigned managed identity does not require elevated rights in Entra upon creation
resource "azurerm_user_assigned_identity" "container_apps_identity" {
  location            = azurerm_resource_group.container_apps_poc.location
  name                = var.containerapps_user_assigned_identity_name
  resource_group_name = azurerm_resource_group.container_apps_poc.name
}

# Role based access control to allow managed identity to pull images from ACR
resource "azurerm_role_assignment" "acrpull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.container_apps_identity.principal_id
}

# Enables output of tenant id etc.
data "azurerm_client_config" "current" {
}

################################################################
### Azure Container Apps (default Consumption-based environment)
################################################################

# Standard environment 
resource "azurerm_container_app_environment" "container_app_environment" {
  name                    = var.containerapps_environment_name
  location                = azurerm_resource_group.container_apps_poc.location
  resource_group_name     = azurerm_resource_group.container_apps_poc.name
}

# Container app with a external (public) ingress that will be exposed on the internet
resource "azurerm_container_app" "api_1_external" {
  name                         = "dev-api-1"
  container_app_environment_id = azurerm_container_app_environment.container_app_environment.id
  resource_group_name          = azurerm_resource_group.container_apps_poc.name
  revision_mode                = "Single" # Set multiple to run multpipe revisions at the same time, traffic splitting etc. 

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_apps_identity.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.container_apps_identity.id
  }

  template {
    container {
      name   = "web-api"
      image  = var.containerapps_image_path # will typically be <acr login server>/<repository>:<tag> (example acrdev.azurecr.io/azurecontainerapps:0.1.1)
      cpu    = 0.25
      memory = "0.5Gi"

      startup_probe {
        path      = "/startup" #Custom startup probe that will check /startup
        port      = 8080
        transport = "HTTP"
      }
    }
  }

  ingress {
    target_port = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
    external_enabled = true
  }
}

###########################################################################
### Azure Container Apps (Dedicated Workload profile environment with VNET)
###########################################################################

# resource "azurerm_virtual_network" "prod_vnet" {
#   name                = var.containerapps_vnet_name
#   address_space       = ["10.0.0.0/20"]
#   location            = azurerm_resource_group.container_apps_poc.location
#   resource_group_name = azurerm_resource_group.container_apps_poc.name
# }

# # Subnet 1, must be exclusive to the Container Apps environment as this will be delegated to Microsoft
# resource "azurerm_subnet" "prod_subnet_1" {
#   name                 = var.containerapps_subnet_delegated_name
#   resource_group_name  = azurerm_resource_group.container_apps_poc.name
#   virtual_network_name = azurerm_virtual_network.prod_vnet.name
#   address_prefixes     = ["10.0.0.0/25"]
#   delegation {
#     name = "delegation"

#     service_delegation {
#       name    = "Microsoft.App/environments"
#       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
#     }
#   }
# }

# # Subnet 2, can be used for connectivity to other services
# resource "azurerm_subnet" "prod_subnet_2" {
#   name                 = var.containerapps_subnet_connectivity_name
#   resource_group_name  = azurerm_resource_group.container_apps_poc.name
#   virtual_network_name = azurerm_virtual_network.prod_vnet.name
#   address_prefixes     = ["10.0.2.0/26"]
# }

# # Creates a workload profile environment that reserves dedicated resources, but can also run Consumption apps in the same environment
# # Note that this environment type can take up to 15 minutes to provision
# resource "azurerm_container_app_environment" "container_app_environment_prod" {
#   name                = var.containerapps_environment_name
#   location            = azurerm_resource_group.container_apps_poc.location
#   resource_group_name = azurerm_resource_group.container_apps_poc.name
#   workload_profile {
#     name                  = var.containerapps_environment_workload_name
#     workload_profile_type = "D4" # Smallest dedicated workload profile
#     maximum_count         = 8
#     minimum_count         = 3
#   }
#   zone_redundancy_enabled  = true
#   infrastructure_subnet_id = azurerm_subnet.prod_subnet_1.id
# }

# resource "azurerm_container_app" "api_1_external_prod" {
#   name                         = "prod-api-1"
#   container_app_environment_id = azurerm_container_app_environment.container_app_environment_prod.id
#   resource_group_name          = azurerm_resource_group.container_apps_poc.name
#   revision_mode                = "Single"

#   identity {
#     type         = "SystemAssigned, UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.container_apps_identity.id]
#   }

#   registry {
#     server   = azurerm_container_registry.acr.login_server
#     identity = azurerm_user_assigned_identity.container_apps_identity.id
#   }

#   template {
#     container {
#       name   = "web-api"
#       image  = var.containerapps_image_path # will typically be <acr login server>/<repository>:<tag> (example acrprodrt.azurecr.io/azurecontainerapps:0.1.1)
#       cpu    = 0.25
#       memory = "0.5Gi"

#       startup_probe {
#         path      = "/startup" #Custom startup probe that will check /startup
#         port      = 8080
#         transport = "HTTP"
#       }
#     }
#   }

#   workload_profile_name = var.containerapps_environment_workload_name # Default value set by Azure if omitted is Consumption

#   ingress {
#     target_port = 8080
#     traffic_weight {
#       percentage      = 100
#       latest_revision = true
#     }
#     external_enabled = true
#   }
# }
