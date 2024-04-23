# Integration testing

## Testcontainers

There are two testprojects present to show a simple example of how integration testing can be done with Testcontainers. Testcontainers is a testing library that provides lightweight APIs for bootstrapping integration tests with real services wrapped in containers. You can write tests talking to the same type of services you use in production without mocks or in-memory services.

More info about Testcontainers can be found here:

- [Introducing Testcontiners](https://testcontainers.com/guides/introducing-testcontainers/) 
- [Testcontainers for .NET](https://dotnet.testcontainers.org/)

The Postgresql test project includes a sample that shows how to run a Postgresql container and a flyway container for database migration that depends on the Postgresql container. 

The Mssql project contains a very simple demo of how to spin up a full SQL Server. SQL Server does not run on Apple silicon, but I have verified that it runs in GitHub Actions. 

## Running test locally

These can be run with the standard `dotnet test`command, i.e. `dotnet test postgresql.tests`, but they require a Docker compatible runtime if you want to run them locally. Many use Rancher Desktop as a free alternative to Docker Desktop, but both can be used if you have a personal preference. 

## Runnign tests in GitHub Actions

GitHub Actions natively support a Docker compatible runtime so these testprojects can be run as they are via `dotnet test` without any more setup in a workflow. This is demonstrated in the [GitHub Actions workflow](../.github/workflows/build.yml)   

