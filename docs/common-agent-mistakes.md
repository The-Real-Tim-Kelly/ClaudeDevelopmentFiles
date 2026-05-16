# Common Agent Mistakes — .NET C# Project

This is a living log of patterns Claude Code (or any AI agent) gets wrong in this codebase. Add entries here as you spot them. Reference this file in your session when you notice recurring issues:

```
@docs/common-agent-mistakes.md
```

Or add a note in `CLAUDE.md` to pull this file in automatically if mistakes become frequent.

---

## Format

Each entry follows this structure:

**Pattern:** What the agent does wrong  
**Why it's wrong:** Short explanation  
**Correct approach:** What to do instead

---

## EF Core

**Pattern:** Generates `ToList()` or `FirstOrDefault()` instead of async equivalents  
**Why it's wrong:** Blocks the thread; violates the async-everywhere convention  
**Correct approach:** Always use `ToListAsync(ct)`, `FirstOrDefaultAsync(ct)`, etc. with the `CancellationToken`

---

**Pattern:** Injects `AppDbContext` directly into a service or controller  
**Why it's wrong:** Violates the repository abstraction — services must not know about EF  
**Correct approach:** Inject `IRepository<T>` or the specific repository interface; `DbContext` belongs only in `Infrastructure`

---

**Pattern:** Uses data annotations (`[Required]`, `[MaxLength]`) on domain entities  
**Why it's wrong:** Couples domain model to EF/validation concerns  
**Correct approach:** Configure everything via `IEntityTypeConfiguration<T>` Fluent API; use FluentValidation for input validation

---

**Pattern:** Forgets `.AsNoTracking()` on read-only queries  
**Why it's wrong:** EF tracks the returned entities unnecessarily, wasting memory  
**Correct approach:** Always add `.AsNoTracking()` for any query that doesn't need change tracking (reads, projections)

---

**Pattern:** Calls `db.Remove(entity)` for soft-delete entities  
**Why it's wrong:** Hard deletes the row; bypasses the soft-delete pattern  
**Correct approach:** Set `entity.IsDeleted = true` and call `UpdateAsync`/`SaveChangesAsync`

---

## DynamoDB

**Pattern:** Hardcodes table names or GSI names as string literals  
**Why it's wrong:** Environment-specific; breaks when deploying to staging/production  
**Correct approach:** Load from `IOptions<DynamoDbOptions>` which is bound from `appsettings.json`

---

**Pattern:** Uses `ScanAsync` to find items  
**Why it's wrong:** Full table scan is expensive and slow; violates the no-scan rule  
**Correct approach:** Design a GSI for the access pattern and use `QueryAsync` against it

---

**Pattern:** Omits the access pattern comment above a DynamoDB query  
**Why it's wrong:** Queries become unmaintainable without knowing what access pattern they serve  
**Correct approach:** Always add a `// Access pattern: ...` comment directly above the query method

---

**Pattern:** Forgets to pass `CancellationToken` to DynamoDB batch operations  
**Why it's wrong:** Batch operations can be long-running; cancellation support is required  
**Correct approach:** `GetRemainingAsync(ct)`, `ExecuteBatchGetAsync(ct)`, `ExecuteBatchWriteAsync(ct)`

---

## ASP.NET Core

**Pattern:** Adds business logic to a controller action  
**Why it's wrong:** Controllers should be thin — only validate input and delegate  
**Correct approach:** Move business logic to the service layer; the controller calls one service method and maps the result to an HTTP response

---

**Pattern:** Returns the domain entity directly from a controller  
**Why it's wrong:** Leaks internal model details; domain entity shape can change independently of the API contract  
**Correct approach:** Always map to a response DTO before returning `Ok(dto)`

---

**Pattern:** Injects `IConfiguration` directly into a service  
**Why it's wrong:** Bypasses typed configuration; makes testing harder  
**Correct approach:** Create a typed options class, bind it in DI, inject `IOptions<TOptions>`

---

## C# General

**Pattern:** Uses `.Result` or `.Wait()` on a `Task`  
**Why it's wrong:** Blocks the thread; can cause deadlocks in ASP.NET Core  
**Correct approach:** Always `await` the `Task`

---

**Pattern:** Suppresses nullable warning with `!` without a comment  
**Why it's wrong:** Silent null risk; masks a real issue  
**Correct approach:** Either handle the null case properly, or add a comment explaining exactly why the null-forgiving operator is safe here

---

**Pattern:** Declares a concrete type for a dependency instead of its interface  
**Why it's wrong:** Tight coupling; breaks testability  
**Correct approach:** Always depend on the interface (`IOrderRepository`, not `OrderRepository`)

---

## Add New Entries Below

<!--
**Pattern:**
**Why it's wrong:**
**Correct approach:**
-->
