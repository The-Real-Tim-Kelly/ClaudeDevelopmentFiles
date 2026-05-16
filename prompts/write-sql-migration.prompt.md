# Write EF Core Migration

> **Claude Code usage:** Copy this prompt into your Claude Code session (or reference with `@prompts/write-sql-migration.prompt.md`), then fill in the **Schema Change Description** section at the bottom.

Describe the schema change you need and this prompt will guide the agent to produce the correct migration or flag a safe multi-step rollout plan.

## What to Generate

1. **Migration class** following the naming convention `YYYYMMDD_ShortDescription`
   - Up() method using `migrationBuilder` operations
   - Down() method that fully reverses the Up() changes
   - All SQL Server-specific types: `NVARCHAR`, `DATETIME2`, `DECIMAL`, `UNIQUEIDENTIFIER`

2. **Breaking change analysis**
   - Flag if this change can cause data loss (column drop, type narrowing, rename)
   - Suggest the safe multi-step rollout for breaking changes:
     1. Add new column (nullable, with default) — deployed first
     2. Backfill existing rows — run separately
     3. Add NOT NULL constraint or rename — deployed after backfill

3. **EF Core model changes** (if any C# entity or configuration needs updating to match)

## Common Migration Patterns

### Add a new column
```csharp
migrationBuilder.AddColumn<string>(
    name: "Email",
    table: "Customer",
    schema: "dbo",
    type: "nvarchar(256)",
    nullable: false,
    defaultValue: "");
```

### Add an index
```csharp
migrationBuilder.CreateIndex(
    name: "IX_Order_CustomerId",
    table: "Order",
    schema: "dbo",
    column: "CustomerId");
```

### Safe rename (two-migration approach)
```csharp
// Migration 1: Add new column
migrationBuilder.AddColumn<string>(name: "NewName", ...);

// Migration 2 (after backfill): Drop old column
migrationBuilder.DropColumn(name: "OldName", ...);
```

## Security Checklist

- [ ] No user-controlled values in migration SQL strings
- [ ] Default values do not expose sensitive data
- [ ] Any new index does not impact a hot table write path without approval

## Schema Change Description

**Fill in before running** — describe the change in plain language, for example:

- Table: `dbo.Order`
- Change: Add a `ShippedAt DATETIME2` nullable column and a non-clustered index on `(CustomerId, ShippedAt)`
- Reason: Support filtering orders by customer and shipping date in the reporting dashboard

> Replace this section with your migration details, then send the full prompt to Claude Code.
