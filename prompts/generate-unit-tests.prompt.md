# Generate Unit Tests

> **Claude Code usage:** Copy this prompt into your Claude Code session (or reference with `@prompts/generate-unit-tests.prompt.md`), then fill in the **Target Class** section at the bottom.

Generate a complete xUnit test class for the target class, following project testing conventions.

## What to Generate

1. **Test class** (`src/MyApp.Tests/<Namespace>/<ClassName>Tests.cs`)
   - Class name: `<ClassName>Tests`
   - Namespace matches the subject class's namespace
   - One `[Fact]` per distinct scenario; use `[Theory]` with `[InlineData]` / `[MemberData]` for parameterized cases
   - Method name format: `MethodName_Scenario_ExpectedResult`

2. **Test setup**
   - Mock all external dependencies with **Moq** (`Mock<IDependency>`)
   - Construct the **subject under test** (SUT) in a shared field or local variable — never mock the SUT itself
   - Use **FluentAssertions** for assertions (`result.Should().Be(...)`, `act.Should().ThrowAsync<...>()`)

3. **Coverage targets** — generate tests for:
   - Happy path (valid input, expected output)
   - Null / missing input edge cases
   - Boundary values
   - Exception paths (what exceptions are thrown and when)
   - Async cancellation if `CancellationToken` is used

## Test Structure Template

```csharp
public sealed class OrderServiceTests
{
    private readonly Mock<IOrderRepository> _repoMock = new();
    private readonly Mock<ILogger<OrderService>> _loggerMock = new();
    private readonly OrderService _sut;

    public OrderServiceTests()
    {
        _sut = new OrderService(_repoMock.Object, _loggerMock.Object);
    }

    [Fact]
    public async Task CreateOrderAsync_ValidRequest_ReturnsCreatedOrderId()
    {
        // Arrange
        var request = new CreateOrderRequest(...);
        _repoMock
            .Setup(r => r.AddAsync(It.IsAny<Order>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        // Act
        var result = await _sut.CreateOrderAsync(request);

        // Assert
        result.Should().NotBeEmpty();
        _repoMock.Verify(r => r.AddAsync(It.IsAny<Order>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task CreateOrderAsync_NullRequest_ThrowsArgumentNullException()
    {
        var act = async () => await _sut.CreateOrderAsync(null!);
        await act.Should().ThrowAsync<ArgumentNullException>();
    }
}
```

## EF Core Integration Tests (SQLite In-Memory)

When testing repositories directly:
```csharp
var options = new DbContextOptionsBuilder<AppDbContext>()
    .UseSqlite("DataSource=:memory:")
    .Options;
using var db = new AppDbContext(options);
db.Database.EnsureCreated();
```

## Target Class

**Fill in before running** — describe the class to test, for example:

- Class: `OrderService`
- Methods to test: `CreateOrderAsync`, `CancelOrderAsync`
- Edge cases: null request, order not found, cancelling an already-shipped order
- Include the file with `@src/MyApp.Application/Services/OrderService.cs`

> Replace this section with your class details, then send the full prompt to Claude Code.
