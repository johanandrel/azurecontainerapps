# azurecontainerapps

PoC with examples on how to provision, build and deploy Azure Container Apps

## Infra

Contains Terraform code to provision resources needed to publish container images from GitHub Actions to Azure Container Registry

## Src

Contains a simple example web api that can be published as a container image without a Dockerfile

## Tests

Contains two sample project that uses Testcontainers to run a Postgresql and a MSSql Server for the purpose of integration testing. 
