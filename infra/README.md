# Infrastructure

## Terraform setup

Create a `.tfvars` file to set your variables, for example `dev.tfvars` 

1. run `terraform init` 
2. set your variables in your `.tfvars` file
3. run `terraform plan -var-file dev.tfvars` 

This example code is typically used durin testing/PoC use and do not have a managed backend for Terraform. You can run `az login` and run this example as log as you have contributor rights in Azure or you can use a dedicated backend of your choice. 

## Resources to enable push to ACR via passwordless login 

The code in this folder creates a resource group, a Container Registry (ACR) and User Assigned Managed Identities to enable passwordless (OIDC) based 
authorization between GitHub and Azure. The Identities use Role Based Access Control to allow to push images from GitHub to ACR (from GitHub Actions) and 
pull images from ACR and deploy them to Azure Container Apps. 

## Setup GitHub Actions to allow passwordless (OIDC) login to Azure

When the resources are provisioned you can visit the repository in GitHub -> Settings -> Secrets and variables -> Actions

Add the following secrets under "Repository secrets". The values can be found in the Terraform output or you can find them in the Azure portal.

`AZURE_SUBSCRIPTION_ID`
`AZURE_TENANT_ID`
`AZURE_CLIENT_ID`
`ACR_LOGIN_SERVER`