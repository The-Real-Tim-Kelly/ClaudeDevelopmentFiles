# ClaudeDevelopmentFiles

Agent configuration and prompt library for **.NET C# development** — optimized for use with **Claude Code** and the **Claude VS Code extension**.

Covers: ASP.NET Core · Entity Framework Core · SQL Server · Amazon DynamoDB · xUnit

---

## What's in This Repository

| Path | Purpose |
|---|---|
| [`CLAUDE.md`](./CLAUDE.md) | Project memory — auto-loaded by Claude Code every session |
| [`AGENTS.md`](./AGENTS.md) | Overview of all agent files and their relationships |
| [`instructions/`](./instructions/) | Detailed coding standards by domain (C#, SQL, EF, DynamoDB) |
| [`prompts/`](./prompts/) | Reusable task prompt templates |
| [`docs/agent-optimization-summary.md`](./docs/agent-optimization-summary.md) | Deep-dive strategy document |

---

## Quick Start

### Step 1 — Copy `CLAUDE.md` to your project

Copy [`CLAUDE.md`](./CLAUDE.md) to the **root of your .NET solution repository**. Claude Code reads it automatically at the start of every session. Update the *Project Structure* section to match your actual solution layout.

### Step 2 — Copy the `instructions/` and `prompts/` folders

Copy both folders into your project root. You can also keep them here and reference them by path.

---

## Using with Claude Code

### Auto-loaded context

`CLAUDE.md` loads every session — no action needed.

### On-demand context (instruction files)

When starting focused work in a specific domain, reference the relevant instruction file at the start of your message:

```
@instructions/entityframework.instructions.md
I need to add a new soft-delete entity for products.
```

```
@instructions/dynamodb.instructions.md
Help me write a query to fetch orders by customer from DynamoDB.
```

### Running a prompt

Reference a prompt file and fill in the blank section at the bottom:

```
@prompts/scaffold-repository.prompt.md
Entity: Order
Extra queries: GetByCustomerIdAsync, GetPendingOrdersAsync
Soft delete: yes
```

Or open the prompt file, fill in the **"Fill in before running"** section at the bottom, then paste the whole file into chat.

---

## Instruction Files

Detailed domain-specific standards to pull in when needed:

| File | Domain | Key Rules |
|---|---|---|
| [`csharp.instructions.md`](./instructions/csharp.instructions.md) | All C# code | Naming, async/await, nullability, LINQ, error handling |
| [`sqlserver.instructions.md`](./instructions/sqlserver.instructions.md) | SQL Server | Parameterization, type choices, NOLOCK rules, schema prefixes |
| [`entityframework.instructions.md`](./instructions/entityframework.instructions.md) | EF Core & Migrations | Repository pattern, async EF, soft delete, Fluent API |
| [`dynamodb.instructions.md`](./instructions/dynamodb.instructions.md) | Amazon DynamoDB | No table scans, access pattern docs, condition expressions |

---

## Prompt Library

Opinionated, reusable task prompts. Reference in Claude Code with `@prompts/<name>` or open the file, fill in the details section at the bottom, and send:

| Prompt | What It Does |
|---|---|
| [`scaffold-ef-entity`](./prompts/scaffold-ef-entity.prompt.md) | Generates a domain entity + `IEntityTypeConfiguration<T>` |
| [`scaffold-repository`](./prompts/scaffold-repository.prompt.md) | Generates a typed repository interface + EF implementation |
| [`write-sql-migration`](./prompts/write-sql-migration.prompt.md) | Plans and writes an EF Core migration with breaking-change analysis |
| [`write-dynamo-query`](./prompts/write-dynamo-query.prompt.md) | Writes a type-safe DynamoDB query with access-pattern documentation |
| [`generate-unit-tests`](./prompts/generate-unit-tests.prompt.md) | Generates xUnit tests with Moq and FluentAssertions |
| [`code-review`](./prompts/code-review.prompt.md) | Structured code review against architecture and security rules |

---

## Further Reading

- [Agent Optimization Strategy](./docs/agent-optimization-summary.md) — why these files exist and how they work together
- [AGENTS.md](./AGENTS.md) — full file inventory and usage hierarchy
