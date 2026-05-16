# CLAUDE.md — Project Memory for Claude Code

This file is automatically read by Claude Code at the start of every session.
Update it to reflect your project's conventions, architecture, and preferences.

---

## Tech Stack

- **Language:** C# (.NET 8+)
- **ORM:** Entity Framework Core (Code-First, Migrations)
- **Relational DB:** SQL Server (Azure SQL or on-prem)
- **NoSQL DB:** Amazon DynamoDB (via AWSSDK.DynamoDBv2)
- **Test Framework:** xUnit + Moq
- **DI Container:** Microsoft.Extensions.DependencyInjection
- **Logging:** Microsoft.Extensions.Logging / Serilog
- **Cloud:** AWS (DynamoDB, potentially S3, SQS, SNS)

---

## Project Structure (Typical)

```
src/
  MyApp.Api/              # ASP.NET Core Web API
  MyApp.Application/      # Application layer (CQRS / services)
  MyApp.Domain/           # Domain entities, interfaces, value objects
  MyApp.Infrastructure/   # EF DbContext, Repositories, DynamoDB clients
  MyApp.Tests/            # xUnit test projects
```

---

## C# Conventions

- Use **PascalCase** for classes, methods, properties, and public fields.
- Use **camelCase** for local variables and parameters.
- Use **\_camelCase** (underscore prefix) for private instance fields.
- Enable **nullable reference types** (`<Nullable>enable</Nullable>`) — handle nulls explicitly.
- Prefer **async/await** end-to-end; suffix async methods with `Async`.
- Use **primary constructors** (.NET 8+) for simple dependency injection.
- Use **records** for immutable DTOs and value objects.
- Prefer **pattern matching** and **switch expressions** over if-else chains.
- Use **LINQ** over manual loops; prefer method syntax over query syntax.
- Never suppress `CS8618` — initialize non-nullable properties properly.

---

## Entity Framework Core Conventions

- Use **Code-First** with migrations (`dotnet ef migrations add <Name>`).
- All DbContext access must go through a **repository interface** — no direct DbContext in controllers or services.
- Always use **async EF methods** (`ToListAsync`, `FirstOrDefaultAsync`, `SaveChangesAsync`).
- **Eager-load** explicitly with `.Include()` / `.ThenInclude()` — lazy loading is disabled.
- Migration naming convention: `YYYYMMDD_ShortDescription` (e.g., `20260516_AddUserEmailIndex`).
- Configure entities using **Fluent API** in `IEntityTypeConfiguration<T>` classes, not data annotations.
- Use **value converters** for enums stored as strings.
- **Soft-delete** pattern: `IsDeleted` bool + global query filter instead of hard deletes.

### Common Commands

```bash
dotnet ef migrations add <MigrationName> --project src/MyApp.Infrastructure --startup-project src/MyApp.Api
dotnet ef database update --project src/MyApp.Infrastructure --startup-project src/MyApp.Api
dotnet ef migrations remove --project src/MyApp.Infrastructure --startup-project src/MyApp.Api
```

---

## SQL Server Conventions

- Always use **parameterized queries** or EF — never build SQL strings with user input.
- Prefix all objects with schema: `dbo.TableName`.
- Use `NOLOCK` hints only in read-heavy reporting queries, never for transactional reads.
- Prefer **stored procedures** for complex multi-step data operations; simple CRUD goes through EF.
- Index strategy: clustered on PK, non-clustered on FK columns and common filter columns.
- Use `NVARCHAR` for variable-length strings; `DATETIME2` instead of `DATETIME`.
- All tables must have a `CreatedAt DATETIME2` and `UpdatedAt DATETIME2` audit column.

---

## DynamoDB (AWS) Conventions

- Use **`AmazonDynamoDBClient`** and **`DynamoDBContext`** from `AWSSDK.DynamoDBv2`.
- Register the client as a **singleton** in DI.
- Use **`[DynamoDBTable]`** and **`[DynamoDBHashKey]`** / **`[DynamoDBRangeKey]`** attributes on model classes.
- Prefer **single-table design** where it reduces GSI complexity; document the access patterns clearly.
- Use **condition expressions** on writes to prevent overwriting unexpected data.
- Batch reads: `BatchGetAsync`; batch writes: `BatchWriteAsync` (max 25 items).
- Never do a **full table scan** in production code — always query a GSI or use the primary key.
- Table names and GSI names belong in `appsettings.json` / AWS Parameter Store — not hardcoded.

---

## Repository Pattern

```csharp
// Interface (Domain layer)
public interface IUserRepository
{
    Task<User?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<IReadOnlyList<User>> GetAllAsync(CancellationToken ct = default);
    Task AddAsync(User user, CancellationToken ct = default);
    Task UpdateAsync(User user, CancellationToken ct = default);
    Task DeleteAsync(Guid id, CancellationToken ct = default);
}

// Implementation (Infrastructure layer — EF or DynamoDB)
public sealed class UserRepository(AppDbContext db) : IUserRepository { ... }
```

---

## Testing Conventions

- Test class name: `<ClassName>Tests` in a matching namespace.
- Use `[Fact]` for single cases, `[Theory]` + `[InlineData]` / `[MemberData]` for parameterized tests.
- Method name pattern: `MethodName_Scenario_ExpectedResult`.
- Use **Moq** to mock dependencies; never mock the subject under test.
- Use **in-memory SQLite** (`UseInMemoryDatabase` or SQLite provider) for EF integration tests.
- Assert with **FluentAssertions** where available.

---

## Important Reminders for the Agent

- Always respect the **repository abstraction** — do not let EF leak into the application layer.
- When generating SQL Server migrations, check for **breaking changes** (column renames, type changes) and generate explicit `RenameColumn` / `AlterColumn` steps.
- When working with DynamoDB, always state the **access pattern** the query is designed to serve.
- Validate all external inputs at the API boundary — never trust data from request bodies without FluentValidation or DataAnnotations.
- Keep secrets out of code — use `IConfiguration`, environment variables, or AWS Secrets Manager.
