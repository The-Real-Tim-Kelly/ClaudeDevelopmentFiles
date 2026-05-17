---
applyTo: '**/*.sql'
---

# SQLite Coding Instructions

> **Claude Code:** Reference this file with `@instructions/sqlite.instructions.md` when working with SQLite.

---

## When to Use SQLite

SQLite is appropriate for:

- Local/embedded applications, desktop apps, mobile apps
- Development and test environments (as a lightweight alternative to a server DB)
- Read-heavy applications with low write concurrency
- Edge deployments, CLI tools, small-scale services (Cloudflare D1, Turso, etc.)

SQLite is **not appropriate** for:

- High-concurrency write workloads (multiple processes/threads writing simultaneously at scale)
- Applications requiring fine-grained access control at the database level
- Situations where the database file must be accessed over a network by multiple clients

---

## Connection Configuration

Always open SQLite with the following pragmas for production use:

```sql
PRAGMA journal_mode = WAL;       -- Write-Ahead Logging: massively improves read/write concurrency
PRAGMA synchronous   = NORMAL;   -- Safe with WAL; faster than FULL
PRAGMA foreign_keys  = ON;       -- Enforce FK constraints (off by default!)
PRAGMA busy_timeout  = 5000;     -- Wait up to 5 seconds if the DB is locked, rather than failing immediately
PRAGMA cache_size    = -64000;   -- 64MB page cache (negative = KB)
PRAGMA temp_store    = MEMORY;   -- Store temp tables in memory
```

In application code, apply these pragmas immediately after every new connection is opened.

---

## Parameterized Queries — Always

```sql
-- Correct: parameterized
SELECT id, email FROM user WHERE email = ?;

-- Correct (named params)
SELECT id, email FROM user WHERE email = :email;

-- NEVER: string concatenation
SELECT id, email FROM user WHERE email = '|| user_input ||';  -- SQL injection
```

This applies regardless of whether the input comes from a user, a config file, or another part of the application.

---

## Schema Design

### Naming

- Table names: **`snake_case`**, singular noun — `order`, `customer`, `product_variant`
- Column names: **`snake_case`** — `customer_id`, `created_at`, `is_deleted`
- Index names: `idx_<table>_<column(s)>` — `idx_order_customer_id`

### Data Types (SQLite Storage Classes)

SQLite uses flexible typing. Use these conventions for clarity:

| Intent                    | SQLite convention                                              |
| ------------------------- | -------------------------------------------------------------- |
| Auto-increment integer PK | `INTEGER PRIMARY KEY` (becomes rowid alias — very fast)        |
| UUID / string ID          | `TEXT NOT NULL`                                                |
| Boolean                   | `INTEGER NOT NULL DEFAULT 0` (0 = false, 1 = true)             |
| Date/time                 | `TEXT NOT NULL` — store as ISO-8601: `2026-05-16T10:00:00Z`    |
| Decimal/money             | `INTEGER` (store as cents/minor unit) — avoid `REAL` for money |
| Large text                | `TEXT`                                                         |
| Binary data               | `BLOB`                                                         |

### Required Columns

Every table should have:

```sql
created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
```

Use a trigger to keep `updated_at` current:

```sql
CREATE TRIGGER update_order_updated_at
AFTER UPDATE ON "order"
BEGIN
    UPDATE "order" SET updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
    WHERE id = NEW.id;
END;
```

---

## Foreign Keys

SQLite **does not enforce foreign keys by default** — you must enable them per connection with `PRAGMA foreign_keys = ON`. This is easy to forget; enforce it at the connection factory level, not at the call site.

---

## Transactions

- Wrap multi-statement writes in an explicit transaction — SQLite is fast within a transaction, and slow with many individual commits
- Use **deferred transactions** (default) for reads; **immediate** or **exclusive** if you know a write is coming:
  ```sql
  BEGIN IMMEDIATE;
  -- your writes
  COMMIT;
  ```
- In application code, always handle rollback on error:
  ```
  begin transaction
  try
    ... all operations ...
    commit
  catch
    rollback
    rethrow
  ```

---

## Migrations

- Use a migration tool appropriate to your stack (**Flyway**, **Liquibase**, **golang-migrate**, **Alembic**, **dbmate**)
- Never modify an already-applied migration — always add a new one
- Migration file naming: `V<number>__<description>.sql` or `<timestamp>_<description>.sql`
- Test every migration against a fresh SQLite file before committing

---

## Indexing

- SQLite automatically creates an index for `PRIMARY KEY` and `UNIQUE` constraints
- Add indexes for columns used in `WHERE`, `ORDER BY`, and `JOIN ON` conditions
- Use **partial indexes** for filtered queries:
  ```sql
  CREATE INDEX idx_order_pending ON "order" (customer_id)
  WHERE status = 'pending';
  ```
- Use `EXPLAIN QUERY PLAN` to verify indexes are being used

---

## Concurrency

- SQLite supports **many concurrent readers** with WAL mode
- SQLite supports only **one writer at a time** — writes block other writes
- In high-write scenarios, use a **single writer connection** or a **connection pool with one write connection** and multiple read connections
- Do not use SQLite with multiple processes writing simultaneously without careful coordination
