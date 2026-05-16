# Scaffold Repository

> **Claude Code usage:** Copy this prompt into your Claude Code session (or reference with `@prompts/scaffold-repository.prompt.md`), then fill in the **Entity / Query Details** section at the bottom.

Generate a complete repository interface and its EF Core implementation following the project's repository pattern.

## What to Generate

Given the entity name (provided below or inferred from the open file), produce:

1. **Repository Interface** (`src/MyApp.Domain/Interfaces/I<Entity>Repository.cs`)
   - Defines the contract for all persistence operations on this entity
   - All methods are async with `CancellationToken ct = default` as the last parameter
   - Return types use `Task<T?>` for single-item lookups (nullable — may not exist)
   - Return `Task<IReadOnlyList<T>>` for collection results
   - Return `Task` (not `Task<int>`) for write operations — EF implementation decides what to expose

2. **EF Core Repository Implementation** (`src/MyApp.Infrastructure/Persistence/Repositories/<Entity>Repository.cs`)
   - Implements the domain interface using `AppDbContext`
   - Uses primary constructor for DI: `public sealed class <Entity>Repository(AppDbContext db)`
   - All queries use `.AsNoTracking()` for reads, tracked context for writes
   - Eager-loads related entities with `.Include()` / `.ThenInclude()` as appropriate
   - Calls `await db.SaveChangesAsync(ct)` inside write methods
   - Soft-delete's `DeleteAsync` sets `entity.IsDeleted = true` and saves — does not call `db.Remove()`

3. **DI Registration snippet** to add to the `AddInfrastructureServices` extension method:
   ```csharp
   services.AddScoped<I<Entity>Repository, <Entity>Repository>();
   ```

## Standard Interface Shape

```csharp
public interface I<Entity>Repository
{
    Task<<Entity>?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<IReadOnlyList<<Entity>>> GetAllAsync(CancellationToken ct = default);
    Task AddAsync(<Entity> entity, CancellationToken ct = default);
    Task UpdateAsync(<Entity> entity, CancellationToken ct = default);
    Task DeleteAsync(Guid id, CancellationToken ct = default);
    // Add domain-specific query methods below:
}
```

## Entity / Query Details

**Fill in before running** — describe the entity and any domain-specific query methods, for example:

- Entity: `Order`
- Extra query methods: `GetByCustomerIdAsync(Guid customerId)`, `GetActiveOrdersAsync()`
- Soft delete: yes

> Replace this section with your entity's details, then send the full prompt to Claude Code.
