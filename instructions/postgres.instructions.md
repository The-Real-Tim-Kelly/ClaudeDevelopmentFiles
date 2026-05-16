# PostgreSQL Coding Instructions

> **Claude Code:** Reference this file with `@instructions/postgres.instructions.md` when working with PostgreSQL.

---

## Naming Conventions

- Tables: **`snake_case`**, singular noun — `order`, `customer`, `product_variant`
- Columns: **`snake_case`** — `customer_id`, `created_at`, `is_deleted`
- Indexes: `idx_<table>_<column(s)>` — `idx_order_customer_id`
- Constraints — Primary key: `pk_<table>` · Foreign key: `fk_<table>_<ref_table>` · Unique: `uq_<table>_<column>`
- Functions / procedures: `snake_case` verbs — `get_orders_by_customer`, `soft_delete_order`
- Avoid reserved keywords as identifiers; if unavoidable, quote with double quotes

---

## Data Types — Prefer These

| Intent | Type |
|---|---|
| Variable-length text | `TEXT` — no need for `VARCHAR(n)` in Postgres; `TEXT` is equally performant |
| Fixed-length codes | `CHAR(n)` only for truly fixed-length (e.g., ISO country codes) |
| Timestamps | `TIMESTAMPTZ` (timestamp with time zone) — **always**, never `TIMESTAMP` |
| Dates only | `DATE` |
| Boolean | `BOOLEAN` |
| Integer IDs | `BIGINT` (or `BIGSERIAL` for auto-increment) |
| UUIDs | `UUID` — use `gen_random_uuid()` (pgcrypto / pg 13+ built-in) |
| Money / decimal | `NUMERIC(p, s)` — never `FLOAT` or `DOUBLE PRECISION` for financial values |
| JSON documents | `JSONB` (binary, indexable) — not `JSON` |
| Arrays | Native array types (`TEXT[]`, `INT[]`) for simple lists |
| Enum-like values | `TEXT` + `CHECK` constraint, or a Postgres `ENUM` type |

---

## Required Columns

Every table should include:

```sql
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Maintain `updated_at` automatically with a trigger:

```sql
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_order_updated_at
BEFORE UPDATE ON "order"
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

---

## Parameterized Queries — Always

```sql
-- Correct (using $1 positional placeholder)
SELECT id, email FROM customer WHERE email = $1;

-- NEVER: string interpolation / concatenation
EXECUTE 'SELECT ... WHERE email = ''' || input_email || '''';  -- SQL injection
```

This applies regardless of the calling language or ORM. Never build SQL strings from user input.

---

## Schema & Migrations

- All objects belong to an explicit schema — default to `public` unless multi-tenancy or separation requires otherwise
- Use a migration tool (**Flyway**, **Liquibase**, **golang-migrate**, **Alembic**, **dbmate**) — never modify an already-applied migration
- Migration naming: `V<number>__<description>.sql` or `<timestamp>_<description>.sql`
- Add new nullable columns or columns with defaults — never add a NOT NULL column without a default to an existing populated table in a single step

---

## Indexes

- Clustered access is based on the physical heap — there is no SQL Server-style clustered index; the primary key creates a `UNIQUE` B-tree index
- Add B-tree indexes for columns used in `WHERE`, `JOIN ON`, `ORDER BY`
- Use **partial indexes** for filtered queries:
  ```sql
  CREATE INDEX idx_order_pending_customer ON "order" (customer_id)
  WHERE status = 'pending';
  ```
- Use **GIN indexes** for `JSONB` columns and full-text search:
  ```sql
  CREATE INDEX idx_product_metadata ON product USING GIN (metadata);
  ```
- Use `EXPLAIN (ANALYZE, BUFFERS)` to verify index usage in query plans

---

## Transactions & Isolation

- Use explicit transactions for multi-statement writes
- Default isolation level (`READ COMMITTED`) is correct for most OLTP workloads
- Use `SERIALIZABLE` or `REPEATABLE READ` only when you need to prevent phantom reads — document why
- Keep transactions **short-lived** — never hold a transaction open while waiting on user input or external calls
- Use `SELECT ... FOR UPDATE` to lock rows you intend to modify within a transaction

---

## Common Patterns

### Soft Delete
```sql
ALTER TABLE "order" ADD COLUMN is_deleted BOOLEAN NOT NULL DEFAULT FALSE;
CREATE INDEX idx_order_not_deleted ON "order" (customer_id) WHERE is_deleted = FALSE;
```

### Upsert
```sql
INSERT INTO customer (id, email, name)
VALUES ($1, $2, $3)
ON CONFLICT (email) DO UPDATE
    SET name       = EXCLUDED.name,
        updated_at = NOW();
```

### Pagination (keyset — prefer over OFFSET for large tables)
```sql
SELECT id, created_at, total
FROM "order"
WHERE customer_id = $1
  AND created_at < $2    -- last seen created_at from previous page
ORDER BY created_at DESC
LIMIT 20;
```

---

## Connection Pooling

- Use **PgBouncer** (transaction mode) or your driver's built-in pool for connection management
- Configure `max_connections` in Postgres conservatively — connections are expensive
- Never open a new connection per request without pooling

---

## Security

- Connect as a **least-privilege role** — application user should not be a superuser
- Grant only required permissions: `GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ... TO app_user`
- Use `REVOKE CREATE ON SCHEMA public FROM PUBLIC` to prevent arbitrary table creation by app users
- Never log query parameters that may contain PII or credentials
- Rotate passwords; store connection strings in environment variables or a secrets manager
