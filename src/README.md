# Samle web app

## Web API

The code in this folder contains a simple web app based on one of Microsofts example apps that contains a simple REST-api. It can be built by running `dotnet build webapi` It also supports being published as a container without using a Dockerfile as .NET have native support for building and publishing containers. 

## GitHub Actions

The code also includes a GitHub Action workflow that demonstrates a simple flow that allows for building the app on `pull request` branches and running all tests using testcontainers. On runs from `main` brach, the workflow logs into Azure with passwordless logon (OIDC) and publishes the app as an image on Azure Container Registry. To enable this you need to see the [infra folder](../infra/README.md) and setup the infrastructure before adding som required values that GitHub Actions use.
