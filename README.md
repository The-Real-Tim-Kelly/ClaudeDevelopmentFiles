# ClaudeDevelopmentFiles

A **language-agnostic agent configuration and prompt library** for use with **Claude Code**, the **Claude VS Code extension**, and **GitHub Copilot**.

Includes a fill-in project memory template (`CLAUDE.md`), a lean Copilot baseline (`.github/copilot-instructions.md`), scoped instruction files for 15 languages and frameworks, expert role/persona files, reusable task prompts, and a setup script for wiring everything into any project.

---

## What's in This Repository

| Path                                                                   | Purpose                                                             |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------- |
| [`CLAUDE.md`](./CLAUDE.md)                                             | Project memory template — auto-loaded by Claude Code every session  |
| [`.github/copilot-instructions.md`](./.github/copilot-instructions.md) | Lean universal baseline — auto-loaded by Copilot every conversation |
| [`AGENTS.md`](./AGENTS.md)                                             | Full inventory of all agent files and their relationships           |
| [`instructions/`](./instructions/)                                     | Coding standards by domain — used by both Claude and Copilot        |
| [`roles/`](./roles/)                                                   | Expert persona files — activate a specialised engineering mindset   |
| [`prompts/`](./prompts/)                                               | Reusable task prompt templates                                      |
| [`scripts/setup-copilot.ps1`](./scripts/setup-copilot.ps1)             | Symlink instruction files into any project for Copilot              |
| [`docs/`](./docs/)                                                     | Strategy docs and common agent mistake log                          |

---

## Quick Start

### Claude Code

**Step 1 — Copy `CLAUDE.md` to your project root.**
Fill in every section: tech stack, folder structure, naming conventions, architecture patterns, common commands. Delete sections that don't apply.

**Step 2 — Copy or reference `instructions/` and `prompts/`.**
You can copy them into your project or keep them here and reference by path.

### GitHub Copilot

Run the setup script once per project — it creates symlinks so instruction files stay in sync with this repo automatically:

```powershell
# C# / ASP.NET Core + SQL Server
.\scripts\setup-copilot.ps1 -ProjectPath "C:\repos\MyApi" `
  -Languages csharp,aspnetcore,entityframework,fluentvalidation `
  -Databases sqlserver

# Python + Postgres
.\scripts\setup-copilot.ps1 -ProjectPath "C:\repos\MyService" `
  -Languages python -Databases postgres

# React + TypeScript
.\scripts\setup-copilot.ps1 -ProjectPath "C:\repos\MyApp" `
  -Languages react

# Everything (polyglot / unsure)
.\scripts\setup-copilot.ps1 -ProjectPath "C:\repos\MyApp" -All
```

The script creates `.github/instructions/` symlinks in the target project and copies the lean `copilot-instructions.md` baseline. Copilot picks them up automatically — no further configuration needed.

---

## Using with Claude Code

### Auto-loaded context

`CLAUDE.md` loads every session automatically — no action needed.

### On-demand context (instruction files)

Reference the relevant instruction file at the start of your message:

```
@instructions/entityframework.instructions.md
I need to add a new soft-delete entity for products.
```

```
@instructions/dynamodb.instructions.md
Help me write a query to fetch orders by customer.
```

### Running a prompt

Reference a prompt file and fill in the details:

```
@prompts/scaffold-repository.prompt.md
Entity: Order
Extra queries: GetByCustomerIdAsync, GetPendingOrdersAsync
Soft delete: yes
```

---

## Using with GitHub Copilot

### Instruction files — auto-applied by file type

Once symlinked into a project via `setup-copilot.ps1`, instruction files apply automatically when you edit matching file types:

| File type              | Auto-applied                                                               |
| ---------------------- | -------------------------------------------------------------------------- |
| `**/*.cs`              | `csharp`, `aspnetcore`, `entityframework`, `fluentvalidation`, `sqlserver` |
| `**/*.py`              | `python`                                                                   |
| `**/*.tsx`, `**/*.jsx` | `react`                                                                    |
| `**/*.go`              | `go`                                                                       |
| `**/*.java`            | `java`                                                                     |
| `**/*.sql`             | `sqlserver`, `postgres`, `sqlite`                                          |
| `**`                   | `observe-first` (always on)                                                |
| Manual only            | `aws`, `dynamodb`, `mongodb` — attach via `#file:` or the paperclip icon   |

### Prompts — available in the prompt picker

All prompt files have `mode: "agent"` frontmatter. In Copilot Chat, open the prompt picker and select the one you need, or reference with `#file:prompts/<name>.prompt.md`.

---

## Instruction Files

| File                                                                  | Domain                                                                |
| --------------------------------------------------------------------- | --------------------------------------------------------------------- |
| [`observe-first`](./instructions/observe-first.instructions.md)       | Always — prioritise existing codebase patterns over any standard      |
| [`csharp`](./instructions/csharp.instructions.md)                     | Naming, async/await, nullability, LINQ, error handling                |
| [`aspnetcore`](./instructions/aspnetcore.instructions.md)             | Thin controllers, DTOs, routing, middleware, error handling           |
| [`fluentvalidation`](./instructions/fluentvalidation.instructions.md) | Validator structure, rule style, registration, async rules            |
| [`sqlserver`](./instructions/sqlserver.instructions.md)               | Parameterization, type choices, NOLOCK rules, schema prefixes         |
| [`entityframework`](./instructions/entityframework.instructions.md)   | Repository pattern, async EF, soft delete, Fluent API                 |
| [`dynamodb`](./instructions/dynamodb.instructions.md)                 | No table scans, access pattern docs, condition expressions            |
| [`aws`](./instructions/aws.instructions.md)                           | S3, SQS, SNS — upload patterns, long polling, ARNs from config        |
| [`java`](./instructions/java.instructions.md)                         | Naming, records, sealed classes, streams, Spring DI, JUnit 5          |
| [`python`](./instructions/python.instructions.md)                     | PEP 8, type hints, Pydantic, async/await, pytest                      |
| [`go`](./instructions/go.instructions.md)                             | Errors as values, interfaces, context, goroutines, table-driven tests |
| [`react`](./instructions/react.instructions.md)                       | Functional components, hooks, TanStack Query, RTL testing             |
| [`sqlite`](./instructions/sqlite.instructions.md)                     | WAL mode, pragmas, types, parameterization, migrations                |
| [`postgres`](./instructions/postgres.instructions.md)                 | TIMESTAMPTZ, JSONB, indexes, transactions, security                   |
| [`mongodb`](./instructions/mongodb.instructions.md)                   | Document design, embed vs reference, indexes, aggregation             |

---

## Prompt Library

All prompts work with both Claude and Copilot. Language-specific variants include framework conventions and code templates; the generic baselines adapt to whatever stack is in use.

### Code Review

| Prompt                                                         | Stack                               |
| -------------------------------------------------------------- | ----------------------------------- |
| [`code-review`](./prompts/code-review.prompt.md)               | Language-agnostic baseline          |
| [`code-review-dotnet`](./prompts/code-review-dotnet.prompt.md) | .NET / ASP.NET Core / EF Core       |
| [`code-review-java`](./prompts/code-review-java.prompt.md)     | Java / Spring Boot / JPA            |
| [`code-review-react`](./prompts/code-review-react.prompt.md)   | React / TypeScript / TanStack Query |
| [`code-review-python`](./prompts/code-review-python.prompt.md) | Python / FastAPI / SQLAlchemy       |

### Unit Tests

| Prompt                                                                         | Stack                          |
| ------------------------------------------------------------------------------ | ------------------------------ |
| [`generate-unit-tests`](./prompts/generate-unit-tests.prompt.md)               | Language-agnostic baseline     |
| [`generate-unit-tests-dotnet`](./prompts/generate-unit-tests-dotnet.prompt.md) | xUnit / Moq / FluentAssertions |
| [`generate-unit-tests-java`](./prompts/generate-unit-tests-java.prompt.md)     | JUnit 5 / Mockito / AssertJ    |
| [`generate-unit-tests-react`](./prompts/generate-unit-tests-react.prompt.md)   | Vitest / React Testing Library |
| [`generate-unit-tests-python`](./prompts/generate-unit-tests-python.prompt.md) | pytest / unittest.mock         |

### Scaffolding & Data

| Prompt                                                                   | What It Does                                                                 |
| ------------------------------------------------------------------------ | ---------------------------------------------------------------------------- |
| [`scaffold-vertical-slice`](./prompts/scaffold-vertical-slice.prompt.md) | Full feature stack: entity + EF config + repo + service + controller + tests |
| [`scaffold-ef-entity`](./prompts/scaffold-ef-entity.prompt.md)           | Domain entity + `IEntityTypeConfiguration<T>`                                |
| [`scaffold-repository`](./prompts/scaffold-repository.prompt.md)         | Repository interface + EF implementation                                     |
| [`write-sql-migration`](./prompts/write-sql-migration.prompt.md)         | EF Core migration with breaking-change analysis                              |
| [`write-dynamo-query`](./prompts/write-dynamo-query.prompt.md)           | Type-safe DynamoDB query with access-pattern docs                            |

### Agent Config

| Prompt                                                               | What It Does                                                   |
| -------------------------------------------------------------------- | -------------------------------------------------------------- |
| [`generate-agent-config`](./prompts/generate-agent-config.prompt.md) | Generate a new instruction, prompt, or role file for this repo |
| [`review-agent-config`](./prompts/review-agent-config.prompt.md)     | Review an existing agent config file for quality and gaps      |

---

## Role Files

Activate an expert persona for a specific task type. Combine with the relevant instruction file for maximum effect:

| Role File                                                              | Persona                  | Best Used For                                     |
| ---------------------------------------------------------------------- | ------------------------ | ------------------------------------------------- |
| [`expert-software-engineer`](./roles/expert-software-engineer.role.md) | Senior Software Engineer | Production-grade implementation                   |
| [`expert-code-reviewer`](./roles/expert-code-reviewer.role.md)         | Principal Code Reviewer  | Structured, adversarial code review               |
| [`expert-test-engineer`](./roles/expert-test-engineer.role.md)         | Senior Test Engineer     | Thorough tests with edge cases and failure paths  |
| [`expert-security-reviewer`](./roles/expert-security-reviewer.role.md) | App Security Engineer    | OWASP Top 10 security audit                       |
| [`expert-architect`](./roles/expert-architect.role.md)                 | Principal Architect      | Design decisions and trade-off analysis           |
| [`expert-debugger`](./roles/expert-debugger.role.md)                   | Debugging Specialist     | Root cause analysis                               |
| [`expert-refactorer`](./roles/expert-refactorer.role.md)               | Refactoring Specialist   | Behaviour-preserving structural improvements      |
| [`expert-database-engineer`](./roles/expert-database-engineer.role.md) | Senior Database Engineer | Schema design, query review, migration safety     |
| [`expert-agent-author`](./roles/expert-agent-author.role.md)           | Agent Config Author      | Writing new instruction, prompt, or role files    |
| [`expert-agent-reviewer`](./roles/expert-agent-reviewer.role.md)       | Agent Config Reviewer    | Reviewing agent config files for quality and gaps |

**Example — security review with domain context:**

```
@roles/expert-security-reviewer.role.md
@instructions/aspnetcore.instructions.md
@src/MyApp.Api/Controllers/OrdersController.cs
Review this controller for security issues.
```

---

## Further Reading

- [AGENTS.md](./AGENTS.md) — full file inventory, Copilot setup details, and usage hierarchy
- [Agent Optimization Strategy](./docs/agent-optimization-summary.md) — why these files exist and how they work together
- [Common Agent Mistakes](./docs/common-agent-mistakes.md) — living log of patterns to watch for

---

## What's in This Repository

| Path                                                                         | Purpose                                                               |
| ---------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| [`CLAUDE.md`](./CLAUDE.md)                                                   | Project memory — auto-loaded by Claude Code every session             |
| [`AGENTS.md`](./AGENTS.md)                                                   | Overview of all agent files and their relationships                   |
| [`instructions/`](./instructions/)                                           | Detailed coding standards by domain (C#, SQL, EF, DynamoDB, and more) |
| [`roles/`](./roles/)                                                         | Expert persona files — activate a specialized engineering mindset     |
| [`prompts/`](./prompts/)                                                     | Reusable task prompt templates                                        |
| [`docs/agent-optimization-summary.md`](./docs/agent-optimization-summary.md) | Deep-dive strategy document                                           |

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

| File                                                                                  | Domain                | Key Rules                                                                                 |
| ------------------------------------------------------------------------------------- | --------------------- | ----------------------------------------------------------------------------------------- |
| [`observe-first.instructions.md`](./instructions/observe-first.instructions.md)       | All languages         | Combine with any instruction file to prioritize existing codebase patterns over standards |
| [`csharp.instructions.md`](./instructions/csharp.instructions.md)                     | All C# code           | Naming, async/await, nullability, LINQ, error handling                                    |
| [`aspnetcore.instructions.md`](./instructions/aspnetcore.instructions.md)             | ASP.NET Core API      | Thin controllers, DTOs, routing, middleware, error handling                               |
| [`fluentvalidation.instructions.md`](./instructions/fluentvalidation.instructions.md) | FluentValidation      | Validator structure, rule style, registration, async rules                                |
| [`sqlserver.instructions.md`](./instructions/sqlserver.instructions.md)               | SQL Server            | Parameterization, type choices, NOLOCK rules, schema prefixes                             |
| [`entityframework.instructions.md`](./instructions/entityframework.instructions.md)   | EF Core & Migrations  | Repository pattern, async EF, soft delete, Fluent API                                     |
| [`dynamodb.instructions.md`](./instructions/dynamodb.instructions.md)                 | Amazon DynamoDB       | No table scans, access pattern docs, condition expressions                                |
| [`aws.instructions.md`](./instructions/aws.instructions.md)                           | AWS (S3, SQS, SNS)    | Upload patterns, long polling, topic ARNs from config                                     |
| [`java.instructions.md`](./instructions/java.instructions.md)                         | Java 21               | Naming, records, sealed classes, streams, Spring DI, JUnit 5                              |
| [`python.instructions.md`](./instructions/python.instructions.md)                     | Python 3.11+          | PEP 8, type hints, Pydantic, async/await, pytest                                          |
| [`go.instructions.md`](./instructions/go.instructions.md)                             | Go 1.22+              | Errors as values, interfaces, context, goroutines, table-driven tests                     |
| [`react.instructions.md`](./instructions/react.instructions.md)                       | React 18 + TypeScript | Functional components, hooks, TanStack Query, RTL testing                                 |
| [`sqlite.instructions.md`](./instructions/sqlite.instructions.md)                     | SQLite                | WAL mode, pragmas, types, parameterization, migrations                                    |
| [`postgres.instructions.md`](./instructions/postgres.instructions.md)                 | PostgreSQL            | Types (TIMESTAMPTZ, JSONB), indexes, transactions, security                               |
| [`mongodb.instructions.md`](./instructions/mongodb.instructions.md)                   | MongoDB               | Document design, embed vs reference, indexes, aggregation                                 |

---

## Prompt Library

Opinionated, reusable task prompts. Reference in Claude Code with `@prompts/<name>` or open the file, fill in the details section at the bottom, and send:

| Prompt                                                                   | What It Does                                                                                     |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| [`scaffold-vertical-slice`](./prompts/scaffold-vertical-slice.prompt.md) | Generates the full stack for a feature: entity + EF config + repo + service + controller + tests |
| [`scaffold-ef-entity`](./prompts/scaffold-ef-entity.prompt.md)           | Generates a domain entity + `IEntityTypeConfiguration<T>`                                        |
| [`scaffold-repository`](./prompts/scaffold-repository.prompt.md)         | Generates a typed repository interface + EF implementation                                       |
| [`write-sql-migration`](./prompts/write-sql-migration.prompt.md)         | Plans and writes an EF Core migration with breaking-change analysis                              |
| [`write-dynamo-query`](./prompts/write-dynamo-query.prompt.md)           | Writes a type-safe DynamoDB query with access-pattern documentation                              |
| [`generate-unit-tests`](./prompts/generate-unit-tests.prompt.md)         | Generates xUnit tests with Moq and FluentAssertions                                              |
| [`code-review`](./prompts/code-review.prompt.md)                         | Structured code review against architecture and security rules                                   |

---

## Further Reading

- [Agent Optimization Strategy](./docs/agent-optimization-summary.md) — why these files exist and how they work together
- [Common Agent Mistakes](./docs/common-agent-mistakes.md) — living log of patterns to watch for; add entries as you find them
- [AGENTS.md](./AGENTS.md) — full file inventory and usage hierarchy

---

## Role Files

Activate an expert persona for a specific task type. Combine with the relevant instruction file for maximum effect:

| Role File                                                              | Persona                  | Best Used For                                    |
| ---------------------------------------------------------------------- | ------------------------ | ------------------------------------------------ |
| [`expert-software-engineer`](./roles/expert-software-engineer.role.md) | Senior Software Engineer | Production-grade implementation                  |
| [`expert-code-reviewer`](./roles/expert-code-reviewer.role.md)         | Principal Code Reviewer  | Structured, adversarial code review              |
| [`expert-test-engineer`](./roles/expert-test-engineer.role.md)         | Senior Test Engineer     | Thorough tests with edge cases and failure paths |
| [`expert-security-reviewer`](./roles/expert-security-reviewer.role.md) | App Security Engineer    | OWASP Top 10 security audit                      |
| [`expert-architect`](./roles/expert-architect.role.md)                 | Principal Architect      | Design decisions and trade-off analysis          |
| [`expert-debugger`](./roles/expert-debugger.role.md)                   | Debugging Specialist     | Root cause analysis                              |
| [`expert-refactorer`](./roles/expert-refactorer.role.md)               | Refactoring Specialist   | Behavior-preserving structural improvements      |
| [`expert-database-engineer`](./roles/expert-database-engineer.role.md) | Senior Database Engineer | Schema design, query review, migration safety    |

**Example — security review with domain context:**

```
@roles/expert-security-reviewer.role.md
@instructions/aspnetcore.instructions.md
@src/MyApp.Api/Controllers/OrdersController.cs
Review this controller for security issues.
```
