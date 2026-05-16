# Scaffold Vertical Slice

> **Claude Code usage:** Reference this with `@prompts/scaffold-vertical-slice.prompt.md` and fill in the **Feature Details** section at the bottom. This generates the complete stack for one feature in a single pass.

---

## What to Generate

Given the feature description below, produce the full vertical slice across all layers:

### 1. Domain Entity + EF Configuration

- Entity in `src/MyApp.Domain/Entities/<EntityName>.cs`
  - Inherits `AuditableEntity` (`CreatedAt`, `UpdatedAt`)
  - Private setters, static `Create(...)` factory, private EF constructor
  - `IsDeleted` + soft-delete if required
- Configuration in `src/MyApp.Infrastructure/Persistence/Configurations/<EntityName>Configuration.cs`
  - `IEntityTypeConfiguration<T>` with full Fluent API (no data annotations)
  - Correct SQL Server types: `NVARCHAR`, `DECIMAL(18,2)`, `DATETIME2`
  - Global query filter if soft-delete applies

### 2. Repository Interface + Implementation

- Interface in `src/MyApp.Domain/Interfaces/I<Entity>Repository.cs`
  - Async methods, `CancellationToken ct = default` on all, typed return types
- Implementation in `src/MyApp.Infrastructure/Persistence/Repositories/<Entity>Repository.cs`
  - Primary constructor `(AppDbContext db)`
  - `.AsNoTracking()` on reads, tracked context on writes
  - Soft-delete's `DeleteAsync` sets `IsDeleted = true`, does not call `db.Remove()`

### 3. Request/Response DTOs

- In `src/MyApp.Application/Models/`
- `Create<Entity>Request` and `Update<Entity>Request` as `sealed record`
- `<Entity>Response` as `sealed record` with all fields the API should expose (no domain entity exposure)

### 4. FluentValidation Validator

- In `src/MyApp.Application/Validators/<Create>Validator.cs` and `<Update>Validator.cs`
- Validates the request records: `NotEmpty`, `MaximumLength`, `EmailAddress`, etc. as appropriate
- Friendly `.WithMessage(...)` on every rule

### 5. Service Interface + Implementation

- Interface in `src/MyApp.Application/Interfaces/I<Entity>Service.cs`
  - Methods: `GetByIdAsync`, `GetAllAsync`, `CreateAsync`, `UpdateAsync`, `DeleteAsync`
- Implementation in `src/MyApp.Application/Services/<Entity>Service.cs`
  - Primary constructor with repository interface + `ILogger<T>`
  - Returns response DTOs — maps from domain entity internally
  - Throws `NotFoundException` for missing records on get/update/delete

### 6. Controller

- In `src/MyApp.Api/Controllers/<Entity>sController.cs`
- `[ApiController]`, `[Route("api/[controller]")]`, derives from `ControllerBase`
- Thin — delegates immediately to service, no business logic
- Correct HTTP method attributes and status codes:
  - `GET /{id}` → `Ok` / `NotFound`
  - `GET /` → `Ok`
  - `POST /` → `CreatedAtAction`
  - `PUT /{id}` → `NoContent` / `NotFound`
  - `DELETE /{id}` → `NoContent` / `NotFound`

### 7. Unit Tests

- In `src/MyApp.Tests/Services/<Entity>ServiceTests.cs`
- Tests for: `GetByIdAsync` (found / not found), `CreateAsync` (success), `UpdateAsync` (success / not found), `DeleteAsync` (success / not found)
- Uses Moq for `I<Entity>Repository`; FluentAssertions for assertions
- Method name pattern: `MethodName_Scenario_ExpectedResult`

### 8. DI Registration Snippet

- Service and repository `AddScoped` registrations to add to the infrastructure/application extension methods

---

## Conventions Reminder

- No `DbContext` outside repositories
- No domain entities in API responses — always map to DTOs
- `CancellationToken` on all async methods, passed through to all downstream calls
- Audit columns (`CreatedAt`, `UpdatedAt`) are set automatically by `AppDbContext.SaveChangesAsync` override
- Soft delete uses global query filter — do not filter `IsDeleted` manually in queries

---

## Feature Details

**Fill in before running** — describe the feature in plain language, for example:

- Entity: `Product`
- Properties: `Name` (string, required, max 200), `Description` (string, optional, max 2000), `Price` (decimal, required), `CategoryId` (Guid, required FK to `Category`)
- Relationships: belongs to `Category`
- Soft delete: yes
- Extra service/query methods: `GetByCategoryAsync(Guid categoryId)`
- Any special validation rules: `Price` must be greater than 0

> Replace this section with your feature's details, then send the full prompt to Claude Code.
