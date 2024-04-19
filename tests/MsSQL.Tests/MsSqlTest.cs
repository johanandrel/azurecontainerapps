namespace MsSQL.Tests;

public sealed class MsSqlTest : IAsyncLifetime
{
    private readonly MsSqlContainer _msSqlContainer
        = new MsSqlBuilder().Build();

    [Fact]
    public async Task ReadFromMsSqlDatabase()
    {
        await using var connection = new SqlConnection(_msSqlContainer.GetConnectionString());
        await connection.OpenAsync();

        await using var command = connection.CreateCommand();
        command.CommandText = "SELECT 1;";

        var actual = await command.ExecuteScalarAsync() as int?;
        Assert.Equal(1, actual.GetValueOrDefault());
    }

    public Task InitializeAsync()
        => _msSqlContainer.StartAsync();

    public Task DisposeAsync()
        => _msSqlContainer.DisposeAsync().AsTask();
}