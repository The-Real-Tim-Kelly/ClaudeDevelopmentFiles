---
mode: 'agent'
description: 'Generate xUnit unit tests for a .NET / ASP.NET Core / EF Core class'
---

# Generate Unit Tests — .NET

> **Claude Code usage:** Reference with `@prompts/generate-unit-tests-dotnet.prompt.md` and include the class file, e.g. `@prompts/generate-unit-tests-dotnet.prompt.md @src/MyApp.Application/Services/OrderService.cs`.

Generate a complete, production-quality xUnit test class for the target .NET class.

> **Scope:** The scenarios listed below are a _minimum baseline_. Add any additional cases you identify as valuable — do not artificially restrict coverage to this list.

## Conventions

| Concern          | Convention                                                        |
| ---------------- | ----------------------------------------------------------------- |
| Test framework   | xUnit (`[Fact]`, `[Theory]`)                                      |
| Mocking          | Moq (`Mock<T>`, `.Setup(...)`, `.Verify(...)`)                    |
| Assertions       | FluentAssertions (`Should().Be(...)`, `Should().ThrowAsync<T>()`) |
| File location    | `src/MyApp.Tests/<Namespace>/<ClassName>Tests.cs`                 |
| Method naming    | `MethodName_Scenario_ExpectedResult`                              |
| SUT construction | Constructor injection — never mock the SUT itself                 |

## What to Generate

1. **Test class** with a constructor that initialises all mocks and builds the SUT
2. **At minimum**, one test per public method covering:
   - Happy path (valid input → expected output / side-effect)
   - Null / empty / missing inputs
   - Boundary values
   - Every distinct exception path
   - `CancellationToken` cancellation if the method accepts one
3. **Mock verification** where the method is required to call a dependency
4. **`[Theory]`** tests for any logic that branches on varying inputs

## Structure Template

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
        var request = new CreateOrderRequest(/* ... */);
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

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    public async Task CreateOrderAsync_InvalidQuantity_ThrowsValidationException(int quantity)
    {
        var request = new CreateOrderRequest(Quantity: quantity);
        var act = async () => await _sut.CreateOrderAsync(request);
        await act.Should().ThrowAsync<ValidationException>();
    }
}
```

## Repository / Integration Tests (SQLite In-Memory)

Use when testing a repository directly against a real `DbContext`:

```csharp
var options = new DbContextOptionsBuilder<AppDbContext>()
    .UseSqlite("DataSource=:memory:")
    .Options;
using var db = new AppDbContext(options);
db.Database.EnsureCreated();
```

## Target Class

**Fill in before running:**

- **Class:** e.g. `OrderService`
- **Methods to test:** e.g. `CreateOrderAsync`, `CancelOrderAsync`
- **Key scenarios / edge cases:** e.g. order not found, already-shipped order, duplicate request
- **File:** include with `@src/MyApp.Application/Services/OrderService.cs`
