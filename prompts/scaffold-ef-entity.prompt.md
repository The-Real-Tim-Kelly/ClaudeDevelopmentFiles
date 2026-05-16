# Scaffold EF Core Entity

> **Claude Code usage:** Copy this prompt into your Claude Code session (or reference with `@prompts/scaffold-ef-entity.prompt.md`), then fill in the **Entity Description** section at the bottom.

Create a complete Entity Framework Core domain entity and its Fluent API configuration class following the project conventions.

## What to Generate

Given the entity name and its properties (provided below or inferred from the open file), produce:

1. **Domain Entity class** (`src/MyApp.Domain/Entities/<EntityName>.cs`)
   - Inherits from `AuditableEntity` (which provides `CreatedAt` / `UpdatedAt`)
   - All properties use C# auto-properties with `{ get; private set; }` (encapsulated setters)
   - Include an `IsDeleted` property if this entity participates in soft delete
   - Include a domain factory method `public static <EntityName> Create(...)` for controlled construction
   - Include a private parameterless constructor for EF Core

2. **EF Core Entity Configuration** (`src/MyApp.Infrastructure/Persistence/Configurations/<EntityName>Configuration.cs`)
   - Implements `IEntityTypeConfiguration<<EntityName>>`
   - Uses `.ToTable("<TableName>", "dbo")`
   - Configures PK, all properties with correct SQL types (`NVARCHAR`, `DECIMAL`, `DATETIME2`, etc.)
   - Configures all relationships with explicit `.HasForeignKey()` and `.OnDelete(DeleteBehavior.Restrict)` unless cascade is specifically justified
   - Adds `HasQueryFilter(e => !e.IsDeleted)` if the entity uses soft delete

## Conventions Checklist

- [ ] No data annotations on the entity class
- [ ] All string properties mapped to `NVARCHAR(n)` with sensible max length
- [ ] All decimal/money properties mapped to `decimal(18,2)`
- [ ] GUID PK uses `UNIQUEIDENTIFIER` (default EF behavior)
- [ ] `CreatedAt` has `HasDefaultValueSql("SYSUTCDATETIME()")` with `ValueGeneratedOnAdd()`
- [ ] `UpdatedAt` has `HasDefaultValueSql("SYSUTCDATETIME()")` with `ValueGeneratedOnAddOrUpdate()`
- [ ] Navigation properties are correctly configured (no lazy loading)

## Entity Description

**Fill in before running** — describe the entity in plain language, for example:

- Entity: `Order`
- Properties: `CustomerId` (Guid, required), `Status` (enum `OrderStatus`), `TotalAmount` (decimal), `Notes` (string, optional, max 1000 chars)
- Relationships: belongs to `Customer`, has many `OrderItems`
- Soft delete: yes

> Replace this section with your entity's details, then send the full prompt to Claude Code.
