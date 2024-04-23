
variable "resource_group_name" {
  type        = string
  description = "Resource group name that is unique in your Azure subscription."
}

variable "resource_group_location" {
  type        = string
  default     = "Norway East"
  description = "Location of the resource group in your Azure subscription."
}

variable "resource_group_tags" {
  type        = map(string)
  description = "Tags to put metadata on the resource group in your Azure subscription."
  default = {
    Owner = "johan.andre.lundar@bekk.no"
  }
}

variable "container_registry_name" {
  type        = string
  default     = ""
  description = "Name of the container registry in your Azure subscription."
}

variable "github_user_assigned_identity_name" {
  type        = string
  default     = ""
  description = "Name of the User Assigned Managed identity that GitHub will use to authenticate against Azure Container Registry."
}

variable "github_repo" {
  type        = string
  default     = ""
  description = "The repository name and location that GitHub Actions will be used in."
}

variable "containerapps_user_assigned_identity_name" {
  type        = string
  default     = ""
  description = "Name of the User Assigned Managed identity that Container Apps will use to authenticate against Azure Container Registry."
}

variable "containerapps_environment_name" {
  type        = string
  description = "Name of the Container App Environment"
}

variable "containerapps_environment_workload_name" {
  type        = string
  description = "Name of the dedicated workload name in the Container App Environment. Will be used by each app should run on that workload"
}

variable "containerapps_vnet_name" {
  type        = string
  description = "Name of the VNET that the Container Apps environment should use"
}

variable "containerapps_subnet_delegated_name" {
  type        = string
  description = "Name of the subnet that will be delegated to manage the Container Apps environment"
}

variable "containerapps_subnet_connectivity_name" {
  type        = string
  description = "Name of the subnet that can be used to connect to other services"
}

variable "containerapps_image_path" {
  type        = string
  description = "Full path of the image to be deployed in the Container Apps Environment (ex: acrprodrt.azurecr.io/azurecontainerapps:0.1.1)"
}