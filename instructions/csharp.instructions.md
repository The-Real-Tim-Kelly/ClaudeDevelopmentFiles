# C# Coding Instructions

> **Claude Code:** Reference this file with `@instructions/csharp.instructions.md` in your session, or drag it into the chat window for focused C# work.

## Naming Conventions

- **PascalCase** for: classes, interfaces, records, enums, methods, properties, events, constants, public fields
- **camelCase** for: local variables, method parameters
- **`_camelCase`** (leading underscore) for: private and protected instance fields
- **I prefix** for interfaces: `IUserRepository`, `IEmailService`
- **Async suffix** for all async methods: `GetUserAsync`, `SaveChangesAsync`
- **T prefix** for generic type parameters: `TEntity`, `TResult`

## Class Design

- Prefer **primary constructors** in .NET 8+ for dependency injection:
  ```csharp
  public sealed class UserService(IUserRepository repo, ILogger<UserService> logger) : IUserService { }
  ```
- Prefer **`sealed`** on concrete classes unless inheritance is intentional
- Use **`record`** or **`record class`** for DTOs, commands, query results, and value objects
- Use **`record struct`** for small, frequently allocated value types

## Nullability

- Nullable reference types are **enabled project-wide** — treat all warnings as errors
- Never use the **null-forgiving operator** (`!`) without an accompanying comment explaining why it is safe
- Prefer **null-coalescing** (`??`) and **null-conditional** (`?.`) over explicit null checks where readable
- Initialize all non-nullable reference type properties in constructors or via required initializers

## Async/Await

- Every `async` method must return `Task`, `Task<T>`, `ValueTask`, or `ValueTask<T>`
- Always include `CancellationToken ct = default` as the last parameter on public async methods
- Pass `ct` through to all downstream async calls — never discard it
- Never use `.Result` or `.Wait()` — always `await`
- Use `ConfigureAwait(false)` in library code (not in ASP.NET Core application code)

## Language Features — Prefer These

```csharp
// Pattern matching switch expression
var label = status switch
{
    OrderStatus.Pending  => "Awaiting payment",
    OrderStatus.Shipped  => "On the way",
    OrderStatus.Delivered => "Delivered",
    _                    => "Unknown"
};

// Property pattern matching
if (user is { IsActive: true, Role: Role.Admin })

// Null coalescing assignment
_cache ??= new Dictionary<string, string>();

// Range and index
var last = items[^1];
var slice = items[1..4];

// LINQ method syntax (preferred over query syntax)
var result = orders
    .Where(o => !o.IsDeleted && o.Status == OrderStatus.Pending)
    .OrderByDescending(o => o.CreatedAt)
    .Select(o => new OrderSummaryDto(o.Id, o.Total))
    .ToList();
```

## Error Handling

- Throw **specific exception types** — avoid throwing `Exception` directly
- Use **custom domain exceptions** (e.g., `NotFoundException`, `ConflictException`) for business rule violations
- Catch exceptions **at boundaries** (controllers, background services) — let them bubble up through the application layer
- Never swallow exceptions with an empty catch block
- Log exceptions with structured context: `logger.LogError(ex, "Failed to process order {OrderId}", orderId)`

## Dependency Injection

- Always depend on **abstractions** (interfaces), not concrete types
- Register services in `Program.cs` via extension methods:
  ```csharp
  builder.Services.AddApplicationServices();
  builder.Services.AddInfrastructureServices(builder.Configuration);
  ```
- Scoped lifetime for repositories and services; Singleton for stateless services and configuration wrappers

## Code Smells to Avoid

- Methods longer than ~30 lines — extract and name sub-operations
- More than 3 parameters on a method — consider a parameter object or record
- Magic numbers and strings — use named constants or configuration values
- Nested ternaries — use a switch expression or local variable
- `static` non-constant mutable state
