# SQL Server Coding Instructions

> **Claude Code:** Reference this file with `@instructions/sqlserver.instructions.md` when writing or reviewing SQL scripts.

## Security — Hard Rules

- **Never concatenate user input into SQL strings** — always use parameterized queries or sp_executesql with parameters
- Never use dynamic SQL unless absolutely necessary; if you must, whitelist allowed values explicitly
- Never SELECT * in production queries — always name the columns you need

## Object Naming

- Always use the **schema prefix**: `dbo.TableName`, `dbo.usp_ProcedureName`
- Tables: singular PascalCase noun — `dbo.Order`, `dbo.ProductVariant`
- Stored procedures: `usp_` prefix — `usp_GetOrdersByCustomer`
- Views: `vw_` prefix — `vw_ActiveProducts`
- Indexes: `IX_TableName_Column(s)` — `IX_Order_CustomerId`
- Primary key constraint: `PK_TableName` — `PK_Order`
- Foreign key constraint: `FK_ChildTable_ParentTable_Column`

## Data Types

- Use **`NVARCHAR`** for all variable-length string columns (supports Unicode)
- Use **`NVARCHAR(MAX)`** only when the value genuinely can exceed 4000 characters
- Use **`DATETIME2(7)`** instead of `DATETIME` — higher precision, larger range, ISO-8601 compatible
- Use **`BIT`** for boolean columns
- Use **`UNIQUEIDENTIFIER`** for distributed-safe primary keys (consider sequential GUIDs via `NEWSEQUENTIALID()`)
- Use **`DECIMAL(p,s)`** for money/currency — never `FLOAT` or `REAL`

## Table Design

- Every table must have:
  - A primary key
  - `CreatedAt DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME()`
  - `UpdatedAt DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME()`
- Soft-delete tables add: `IsDeleted BIT NOT NULL DEFAULT 0` + index on `IsDeleted`
- Foreign key columns are always indexed

## Query Style

```sql
-- Good: explicit column list, aliased tables, schema-prefixed, parameterized
SELECT
    o.Id,
    o.OrderDate,
    c.Email    AS CustomerEmail,
    o.TotalAmount
FROM dbo.[Order] o
INNER JOIN dbo.Customer c ON c.Id = o.CustomerId
WHERE o.CustomerId = @CustomerId
  AND o.IsDeleted   = 0
ORDER BY o.OrderDate DESC;
```

## NOLOCK / Hints

- Use `WITH (NOLOCK)` **only** in read-heavy reporting queries where dirty reads are acceptable
- Never use `NOLOCK` on transactional reads (order processing, payment, inventory updates)
- Always add a comment when using `NOLOCK` explaining why it's acceptable here

## Stored Procedures & Functions

- Stored procedures for multi-step operations or complex queries that benefit from plan caching
- Table-valued functions for reusable row-returning logic
- Always include `SET NOCOUNT ON` at the top of stored procedures
- Include a header comment block on every procedure:

```sql
-- ===========================================================================
-- Procedure : dbo.usp_GetOrdersByCustomer
-- Purpose   : Returns all non-deleted orders for a given customer, newest first
-- Parameters: @CustomerId UNIQUEIDENTIFIER
-- Author    : <Name>
-- Created   : YYYY-MM-DD
-- ===========================================================================
```

## Indexing Guidelines

- Clustered index on the primary key (default)
- Non-clustered indexes on: foreign key columns, common WHERE filter columns, ORDER BY columns
- Covering indexes (INCLUDE columns) for frequently run queries fetching a small number of additional columns
- Do not index every column — over-indexing hurts write performance

## Transactions

- Use explicit transactions (`BEGIN TRAN / COMMIT / ROLLBACK`) for multi-statement operations
- Keep transactions as short as possible — no user interaction inside a transaction
- Use `TRY...CATCH` with `ROLLBACK` in the catch block for stored procedures that modify data

## Migrations (EF Core)

- Generated migration scripts go through code review before being run in staging/production
- Breaking changes (column rename, type change, drop) require a **non-breaking multi-step rollout**:
  1. Add new column / table
  2. Dual-write in application code
  3. Backfill data
  4. Drop old column in a separate migration
