# ClaudeDevelopmentFiles

A **language-agnostic agent configuration and prompt library** for use with **Claude Code** and the **Claude VS Code extension**.

Includes a fill-in project memory template (`CLAUDE.md`), scoped instruction files for 15 languages and frameworks, expert role/persona files, reusable task prompts, and supporting docs.

---

## What's in This Repository

| Path | Purpose |
|---|---|
| [`CLAUDE.md`](./CLAUDE.md) | Project memory — auto-loaded by Claude Code every session |
| [`AGENTS.md`](./AGENTS.md) | Overview of all agent files and their relationships |
| [`instructions/`](./instructions/) | Detailed coding standards by domain (C#, SQL, EF, DynamoDB, and more) |
| [`roles/`](./roles/) | Expert persona files — activate a specialized engineering mindset |
| [`prompts/`](./prompts/) | Reusable task prompt templates |
| [`docs/agent-optimization-summary.md`](./docs/agent-optimization-summary.md) | Deep-dive strategy document |

---

## Quick Start

### Step 1 — Copy `CLAUDE.md` to your project

Copy [`CLAUDE.md`](./CLAUDE.md) to the **root of your project**. Claude Code reads it automatically at the start of every session. Fill in every section — tech stack, folder structure, naming conventions, architecture patterns, and common commands — for your specific project. Delete sections that don't apply.

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
| [`observe-first.instructions.md`](./instructions/observe-first.instructions.md) | All languages | Combine with any instruction file to prioritize existing codebase patterns over standards |
| [`csharp.instructions.md`](./instructions/csharp.instructions.md) | All C# code | Naming, async/await, nullability, LINQ, error handling |
| [`aspnetcore.instructions.md`](./instructions/aspnetcore.instructions.md) | ASP.NET Core API | Thin controllers, DTOs, routing, middleware, error handling |
| [`fluentvalidation.instructions.md`](./instructions/fluentvalidation.instructions.md) | FluentValidation | Validator structure, rule style, registration, async rules |
| [`sqlserver.instructions.md`](./instructions/sqlserver.instructions.md) | SQL Server | Parameterization, type choices, NOLOCK rules, schema prefixes |
| [`entityframework.instructions.md`](./instructions/entityframework.instructions.md) | EF Core & Migrations | Repository pattern, async EF, soft delete, Fluent API |
| [`dynamodb.instructions.md`](./instructions/dynamodb.instructions.md) | Amazon DynamoDB | No table scans, access pattern docs, condition expressions |
| [`aws.instructions.md`](./instructions/aws.instructions.md) | AWS (S3, SQS, SNS) | Upload patterns, long polling, topic ARNs from config |
| [`java.instructions.md`](./instructions/java.instructions.md) | Java 21 | Naming, records, sealed classes, streams, Spring DI, JUnit 5 |
| [`python.instructions.md`](./instructions/python.instructions.md) | Python 3.11+ | PEP 8, type hints, Pydantic, async/await, pytest |
| [`go.instructions.md`](./instructions/go.instructions.md) | Go 1.22+ | Errors as values, interfaces, context, goroutines, table-driven tests |
| [`react.instructions.md`](./instructions/react.instructions.md) | React 18 + TypeScript | Functional components, hooks, TanStack Query, RTL testing |
| [`sqlite.instructions.md`](./instructions/sqlite.instructions.md) | SQLite | WAL mode, pragmas, types, parameterization, migrations |
| [`postgres.instructions.md`](./instructions/postgres.instructions.md) | PostgreSQL | Types (TIMESTAMPTZ, JSONB), indexes, transactions, security |
| [`mongodb.instructions.md`](./instructions/mongodb.instructions.md) | MongoDB | Document design, embed vs reference, indexes, aggregation |

---

## Prompt Library

Opinionated, reusable task prompts. Reference in Claude Code with `@prompts/<name>` or open the file, fill in the details section at the bottom, and send:

| Prompt | What It Does |
|---|---|
| [`scaffold-vertical-slice`](./prompts/scaffold-vertical-slice.prompt.md) | Generates the full stack for a feature: entity + EF config + repo + service + controller + tests |
| [`scaffold-ef-entity`](./prompts/scaffold-ef-entity.prompt.md) | Generates a domain entity + `IEntityTypeConfiguration<T>` |
| [`scaffold-repository`](./prompts/scaffold-repository.prompt.md) | Generates a typed repository interface + EF implementation |
| [`write-sql-migration`](./prompts/write-sql-migration.prompt.md) | Plans and writes an EF Core migration with breaking-change analysis |
| [`write-dynamo-query`](./prompts/write-dynamo-query.prompt.md) | Writes a type-safe DynamoDB query with access-pattern documentation |
| [`generate-unit-tests`](./prompts/generate-unit-tests.prompt.md) | Generates xUnit tests with Moq and FluentAssertions |
| [`code-review`](./prompts/code-review.prompt.md) | Structured code review against architecture and security rules |

---

## Further Reading

- [Agent Optimization Strategy](./docs/agent-optimization-summary.md) — why these files exist and how they work together
- [Common Agent Mistakes](./docs/common-agent-mistakes.md) — living log of patterns to watch for; add entries as you find them
- [AGENTS.md](./AGENTS.md) — full file inventory and usage hierarchy

---

## Role Files

Activate an expert persona for a specific task type. Combine with the relevant instruction file for maximum effect:

| Role File | Persona | Best Used For |
|---|---|---|
| [`expert-software-engineer`](./roles/expert-software-engineer.role.md) | Senior Software Engineer | Production-grade implementation |
| [`expert-code-reviewer`](./roles/expert-code-reviewer.role.md) | Principal Code Reviewer | Structured, adversarial code review |
| [`expert-test-engineer`](./roles/expert-test-engineer.role.md) | Senior Test Engineer | Thorough tests with edge cases and failure paths |
| [`expert-security-reviewer`](./roles/expert-security-reviewer.role.md) | App Security Engineer | OWASP Top 10 security audit |
| [`expert-architect`](./roles/expert-architect.role.md) | Principal Architect | Design decisions and trade-off analysis |
| [`expert-debugger`](./roles/expert-debugger.role.md) | Debugging Specialist | Root cause analysis |
| [`expert-refactorer`](./roles/expert-refactorer.role.md) | Refactoring Specialist | Behavior-preserving structural improvements |
| [`expert-database-engineer`](./roles/expert-database-engineer.role.md) | Senior Database Engineer | Schema design, query review, migration safety |

**Example — security review with domain context:**

```
@roles/expert-security-reviewer.role.md
@instructions/aspnetcore.instructions.md
@src/MyApp.Api/Controllers/OrdersController.cs
Review this controller for security issues.
```
