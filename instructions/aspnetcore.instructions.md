# ASP.NET Core API Instructions

> **Claude Code:** Reference this file with `@instructions/aspnetcore.instructions.md` when working on controllers, endpoints, middleware, or API project setup.

---

## Controller Conventions

- Controllers are **thin** — no business logic, no direct database access
- One controller per top-level resource (e.g., `OrdersController`, `CustomersController`)
- Inject **service interfaces**, never repositories or `DbContext` directly
- Derive from `ControllerBase` (not `Controller` — no view support needed in an API)
- Decorate with `[ApiController]` and `[Route("api/[controller]")]`

```csharp
[ApiController]
[Route("api/[controller]")]
public sealed class OrdersController(IOrderService orderService) : ControllerBase
{
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<OrderResponse>> GetById(
        Guid id, CancellationToken ct)
    {
        var order = await orderService.GetByIdAsync(id, ct);
        return order is null ? NotFound() : Ok(order);
    }
}
```

## Return Types

- Use **typed `ActionResult<T>`** on all endpoints — never raw `IActionResult` unless the response shape is genuinely dynamic
- Use the correct HTTP status helpers:

| Scenario           | Return                                                              |
| ------------------ | ------------------------------------------------------------------- |
| Success with body  | `Ok(result)`                                                        |
| Created resource   | `CreatedAtAction(nameof(GetById), new { id }, result)`              |
| No content         | `NoContent()`                                                       |
| Not found          | `NotFound()`                                                        |
| Validation failure | `BadRequest(ModelState)` or let `[ApiController]` handle it         |
| Conflict           | `Conflict(new ProblemDetails { ... })`                              |
| Unhandled error    | Let middleware return 500 — do not catch and swallow in controllers |

## Request & Response DTOs

- Keep request and response DTOs in the **Application layer** (`MyApp.Application/Models/`)
- Name clearly: `CreateOrderRequest`, `OrderResponse`, `UpdateOrderRequest`
- Use **`record`** for immutable request/response types:
  ```csharp
  public sealed record CreateOrderRequest(Guid CustomerId, List<OrderItemRequest> Items);
  public sealed record OrderResponse(Guid Id, string Status, decimal Total, DateTime CreatedAt);
  ```
- Never expose domain entities directly from API endpoints — always map to a response DTO

## Routing

- Use **lowercase kebab-case** route segments: `api/orders`, `api/order-items`
- Use route constraints for typed parameters: `{id:guid}`, `{page:int:min(1)}`
- Group related endpoints with a consistent prefix — prefer resource nesting only one level deep: `api/customers/{customerId}/orders`
- Avoid using query strings for anything that identifies a resource — use route segments

## Validation

- **Never manually check `ModelState.IsValid`** — `[ApiController]` returns a 400 automatically for data annotation failures
- Use **FluentValidation** for all meaningful business-rule validation (see `fluentvalidation.instructions.md`)
- Register FluentValidation with the ASP.NET pipeline so validation errors return a standard `ValidationProblemDetails` shape
- Validation is the **controller's only responsibility** before calling the service — if it passes, delegate immediately

## Error Handling & Problem Details

- Use a global exception-handling middleware (not try/catch in every controller) to catch domain exceptions and map them to RFC 7807 `ProblemDetails` responses
- Standard mappings:

```csharp
// In exception-handling middleware
NotFoundException    → 404 Not Found
ConflictException    → 409 Conflict
ValidationException  → 422 Unprocessable Entity
UnauthorizedException → 401 Unauthorized
ForbiddenException  → 403 Forbidden
// Everything else → 500 Internal Server Error (no detail in response body)
```

- Never return stack traces or internal exception messages in production responses
- Always return `application/problem+json` content type for errors

## Middleware Order (Program.cs)

Middleware must be registered in this order:

```csharp
app.UseExceptionHandler("/error");   // or custom middleware — must be first
app.UseHttpsRedirection();
app.UseRouting();
app.UseCors();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
```

## Dependency Registration Pattern

Use extension methods to keep `Program.cs` clean:

```csharp
// Program.cs
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);
builder.Services.AddApiServices();

// ApiServiceExtensions.cs
public static class ApiServiceExtensions
{
    public static IServiceCollection AddApiServices(this IServiceCollection services)
    {
        services.AddControllers();
        services.AddFluentValidationAutoValidation();
        services.AddValidatorsFromAssembly(typeof(ApiServiceExtensions).Assembly);
        return services;
    }
}
```

## Configuration

- Never inject `IConfiguration` directly into controllers or services — use `IOptions<T>`
- Bind configuration sections in `Program.cs` or a registration extension:
  ```csharp
  builder.Services.Configure<DynamoDbOptions>(
      builder.Configuration.GetSection(DynamoDbOptions.SectionName));
  ```
- Validate options on startup with `.ValidateDataAnnotations().ValidateOnStart()`

## Security Checklist

- All endpoints require `[Authorize]` unless explicitly `[AllowAnonymous]`
- Sensitive endpoints use `[Authorize(Roles = "...")]` or policy-based authorization
- Never log request bodies that may contain PII or credentials
- Rate-limit public endpoints
- Enable HTTPS redirection and HSTS in production
