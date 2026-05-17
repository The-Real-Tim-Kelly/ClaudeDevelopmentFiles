# AGENTS.md — AI Agent Configuration Overview

This file documents all agent configuration files in this repository and explains how each one is used.

---

## What Are These Files For?

When working with AI coding agents (Claude Code, GitHub Copilot, Claude VS Code extension), the quality of results improves significantly when the agent is given **persistent context** about your project. Without it, the agent defaults to generic patterns that may not match your architecture, naming conventions, or tech stack.

This repository provides a set of files that feed the right context to both Claude and Copilot — automatically on session start, or on demand during a session.

---

## GitHub Copilot Setup

All instruction and prompt files are dual-compatible with both Claude and Copilot.

### For this repository

The `.github/copilot-instructions.md` file is auto-loaded by Copilot every conversation.
Instruction files have `applyTo` frontmatter so Copilot applies them automatically based on file type.
Prompt files have `mode: "agent"` frontmatter and appear in Copilot's prompt picker.

### For other projects (one-time setup per project)

Run the setup script to symlink instruction files into your project — no file copying, changes here are reflected everywhere:

```powershell
# C# / ASP.NET Core + SQL Server project
.\scripts\setup-copilot.ps1 -ProjectPath "C:\repos\MyApi" `
  -Languages csharp,aspnetcore,entityframework,fluentvalidation `
  -Databases sqlserver

# Python + Postgres project
.\scripts\setup-copilot.ps1 -ProjectPath "C:\repos\MyService" `
  -Languages python -Databases postgres

# Everything (polyglot / unsure)
.\scripts\setup-copilot.ps1 -ProjectPath "C:\repos\MyApp" -All
```

The script creates `.github/instructions/` symlinks in the target project and copies the lean `copilot-instructions.md` baseline. No project-specific information needed — Copilot picks up the files automatically.

### How instruction files auto-apply (token-efficient)

| File type                                                                  | Auto-applied to                                         |
| -------------------------------------------------------------------------- | ------------------------------------------------------- |
| `csharp`, `aspnetcore`, `entityframework`, `fluentvalidation`, `sqlserver` | `**/*.cs`, `**/*.sql`                                   |
| `python`                                                                   | `**/*.py`                                               |
| `react`                                                                    | `**/*.tsx`, `**/*.jsx`                                  |
| `go`                                                                       | `**/*.go`                                               |
| `java`                                                                     | `**/*.java`                                             |
| `postgres`, `sqlite`                                                       | `**/*.sql`                                              |
| `observe-first`                                                            | `**` (always on)                                        |
| `aws`, `dynamodb`, `mongodb`                                               | Manual only — attach via `#file:` or the paperclip icon |

> **Note:** Only symlink the instruction files relevant to your project. Fewer active instruction files = fewer tokens per request.

---

## File Inventory

### Core Memory / Baseline Files

| File                                                                   | Consumed By                                | When                             |
| ---------------------------------------------------------------------- | ------------------------------------------ | -------------------------------- |
| [`CLAUDE.md`](./CLAUDE.md)                                             | Claude Code CLI + Claude VS Code extension | Automatically at session start   |
| [`.github/copilot-instructions.md`](./.github/copilot-instructions.md) | GitHub Copilot                             | Automatically every conversation |

### Detailed Context Files (On Demand)

These files extend the baselines with deeper, domain-specific rules. Both Claude and Copilot can use them.

| File                                                                                               | Covers                                                    | Claude                                           | Copilot                    |
| -------------------------------------------------------------------------------------------------- | --------------------------------------------------------- | ------------------------------------------------ | -------------------------- |
| [`instructions/observe-first.instructions.md`](./instructions/observe-first.instructions.md)       | Prioritize existing codebase patterns                     | `@instructions/observe-first.instructions.md`    | Auto (`**`)                |
| [`instructions/csharp.instructions.md`](./instructions/csharp.instructions.md)                     | C# naming, async, nullability, patterns                   | `@instructions/csharp.instructions.md`           | Auto (`**/*.cs`)           |
| [`instructions/aspnetcore.instructions.md`](./instructions/aspnetcore.instructions.md)             | Controllers, routing, middleware, error handling          | `@instructions/aspnetcore.instructions.md`       | Auto (`**/*.cs`)           |
| [`instructions/fluentvalidation.instructions.md`](./instructions/fluentvalidation.instructions.md) | Validator structure, rules, registration                  | `@instructions/fluentvalidation.instructions.md` | Auto (`**/*.cs`)           |
| [`instructions/sqlserver.instructions.md`](./instructions/sqlserver.instructions.md)               | SQL types, parameterization, NOLOCK, indexes              | `@instructions/sqlserver.instructions.md`        | Auto (`**/*.sql,**/*.cs`)  |
| [`instructions/entityframework.instructions.md`](./instructions/entityframework.instructions.md)   | EF Core, repository pattern, migrations                   | `@instructions/entityframework.instructions.md`  | Auto (`**/*.cs`)           |
| [`instructions/dynamodb.instructions.md`](./instructions/dynamodb.instructions.md)                 | DynamoDB key design, queries, GSIs                        | `@instructions/dynamodb.instructions.md`         | Manual (`#file:`)          |
| [`instructions/aws.instructions.md`](./instructions/aws.instructions.md)                           | S3, SQS, SNS patterns and conventions                     | `@instructions/aws.instructions.md`              | Manual (`#file:`)          |
| [`instructions/java.instructions.md`](./instructions/java.instructions.md)                         | Java 21, naming, records, streams, Spring DI              | `@instructions/java.instructions.md`             | Auto (`**/*.java`)         |
| [`instructions/python.instructions.md`](./instructions/python.instructions.md)                     | Python 3.11+, type hints, Pydantic, async, pytest         | `@instructions/python.instructions.md`           | Auto (`**/*.py`)           |
| [`instructions/go.instructions.md`](./instructions/go.instructions.md)                             | Go conventions, errors, interfaces, context, goroutines   | `@instructions/go.instructions.md`               | Auto (`**/*.go`)           |
| [`instructions/react.instructions.md`](./instructions/react.instructions.md)                       | React 18+, TypeScript, hooks, state, TanStack Query       | `@instructions/react.instructions.md`            | Auto (`**/*.tsx,**/*.jsx`) |
| [`instructions/sqlite.instructions.md`](./instructions/sqlite.instructions.md)                     | SQLite pragmas, WAL mode, types, migrations               | `@instructions/sqlite.instructions.md`           | Auto (`**/*.sql`)          |
| [`instructions/postgres.instructions.md`](./instructions/postgres.instructions.md)                 | PostgreSQL types, indexes, transactions, security         | `@instructions/postgres.instructions.md`         | Auto (`**/*.sql`)          |
| [`instructions/mongodb.instructions.md`](./instructions/mongodb.instructions.md)                   | MongoDB schema design, indexes, aggregation, transactions | `@instructions/mongodb.instructions.md`          | Manual (`#file:`)          |

### Reusable Prompt Files (On Demand)

Pre-written, opinionated task prompts. Reference them in Claude Code or paste them into chat, then fill in the task-specific details at the bottom of each file.

| File                                                                                             | Purpose                                             |
| ------------------------------------------------------------------------------------------------ | --------------------------------------------------- |
| [`prompts/scaffold-vertical-slice.prompt.md`](./prompts/scaffold-vertical-slice.prompt.md)       | Scaffold the full stack for a feature in one pass   |
| [`prompts/scaffold-ef-entity.prompt.md`](./prompts/scaffold-ef-entity.prompt.md)                 | Scaffold an EF Core entity + Fluent config          |
| [`prompts/scaffold-repository.prompt.md`](./prompts/scaffold-repository.prompt.md)               | Scaffold a repository interface + implementation    |
| [`prompts/write-sql-migration.prompt.md`](./prompts/write-sql-migration.prompt.md)               | Generate an EF Core migration script                |
| [`prompts/write-dynamo-query.prompt.md`](./prompts/write-dynamo-query.prompt.md)                 | Write a type-safe DynamoDB query                    |
| [`prompts/generate-unit-tests.prompt.md`](./prompts/generate-unit-tests.prompt.md)               | Generate unit tests — language-agnostic baseline    |
| [`prompts/generate-unit-tests-dotnet.prompt.md`](./prompts/generate-unit-tests-dotnet.prompt.md) | Unit tests — .NET / xUnit / Moq / FluentAssertions  |
| [`prompts/generate-unit-tests-java.prompt.md`](./prompts/generate-unit-tests-java.prompt.md)     | Unit tests — Java / JUnit 5 / Mockito / AssertJ     |
| [`prompts/generate-unit-tests-react.prompt.md`](./prompts/generate-unit-tests-react.prompt.md)   | Unit tests — React / Vitest / React Testing Library |
| [`prompts/generate-unit-tests-python.prompt.md`](./prompts/generate-unit-tests-python.prompt.md) | Unit tests — Python / pytest / unittest.mock        |
| [`prompts/code-review.prompt.md`](./prompts/code-review.prompt.md)                               | Code review — language-agnostic baseline            |
| [`prompts/code-review-dotnet.prompt.md`](./prompts/code-review-dotnet.prompt.md)                 | Code review — .NET / ASP.NET Core / EF Core         |
| [`prompts/code-review-java.prompt.md`](./prompts/code-review-java.prompt.md)                     | Code review — Java / Spring Boot / JPA              |
| [`prompts/code-review-react.prompt.md`](./prompts/code-review-react.prompt.md)                   | Code review — React / TypeScript / TanStack Query   |
| [`prompts/code-review-python.prompt.md`](./prompts/code-review-python.prompt.md)                 | Code review — Python / FastAPI / SQLAlchemy         |
| [`prompts/generate-agent-config.prompt.md`](./prompts/generate-agent-config.prompt.md)           | Generate a new instruction, prompt, or role file    |
| [`prompts/review-agent-config.prompt.md`](./prompts/review-agent-config.prompt.md)               | Review an existing agent config file for quality    |

### Role / Persona Files (On Demand)

Activate an expert persona for a specific type of task. Combine with instruction files for maximum precision.

| File                                                                                 | Role                          | When to Use                                                   |
| ------------------------------------------------------------------------------------ | ----------------------------- | ------------------------------------------------------------- |
| [`roles/expert-software-engineer.role.md`](./roles/expert-software-engineer.role.md) | Senior Software Engineer      | Writing or completing production-grade implementation         |
| [`roles/expert-code-reviewer.role.md`](./roles/expert-code-reviewer.role.md)         | Principal Code Reviewer       | Adversarial, structured review of a file or PR                |
| [`roles/expert-test-engineer.role.md`](./roles/expert-test-engineer.role.md)         | Senior Test Engineer          | Writing thorough tests including edge cases and failure paths |
| [`roles/expert-security-reviewer.role.md`](./roles/expert-security-reviewer.role.md) | Application Security Engineer | Security audit against OWASP Top 10                           |
| [`roles/expert-architect.role.md`](./roles/expert-architect.role.md)                 | Principal Architect           | Design decisions, trade-off analysis, system structure        |
| [`roles/expert-debugger.role.md`](./roles/expert-debugger.role.md)                   | Debugging Specialist          | Root cause analysis of bugs and unexpected behavior           |
| [`roles/expert-refactorer.role.md`](./roles/expert-refactorer.role.md)               | Refactoring Specialist        | Behavior-preserving structural improvements                   |
| [`roles/expert-database-engineer.role.md`](./roles/expert-database-engineer.role.md) | Senior Database Engineer      | Schema design, query review, migration safety                 |

### Documentation

| File                                                                         | Purpose                                                                    |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| [`docs/agent-optimization-summary.md`](./docs/agent-optimization-summary.md) | Deep-dive on the strategy behind all these files                           |
| [`docs/common-agent-mistakes.md`](./docs/common-agent-mistakes.md)           | Living log of patterns the agent gets wrong — add entries as you find them |
| [`README.md`](./README.md)                                                   | Getting started guide                                                      |

### Setup Scripts

| File                                                       | Purpose                                                     |
| ---------------------------------------------------------- | ----------------------------------------------------------- |
| [`scripts/setup-copilot.ps1`](./scripts/setup-copilot.ps1) | Symlink instruction files into a target project for Copilot |

---

## File Priority & Usage Hierarchy

```
CLAUDE.md                          ← Auto-loaded every Claude Code session (highest trust)
.github/copilot-instructions.md    ← Auto-loaded every Copilot conversation
instructions/*.instructions.md     ← Reference on demand for focused domain work
roles/*.role.md                    ← Reference on demand to activate an expert persona
prompts/*.prompt.md                ← Reference on demand for reusable task execution
```

---

## Key Principles

1. **`CLAUDE.md` is the always-on Claude baseline** — it covers the full stack at a summary level and is automatically loaded every Claude Code session.
2. **`.github/copilot-instructions.md` is the always-on Copilot baseline** — lean universal rules, no project-specific placeholders.
3. **Instruction files are on-demand depth** — pull them in when you're doing focused work in a specific area (EF migrations, DynamoDB queries, etc.).
4. **Role files activate an expert persona** — combine with the relevant instruction file to get both the mindset and the domain standards in one session.
5. **Prompts are reusable task macros** — each prompt bakes in your architecture standards so you only need to provide the task-specific inputs.
6. **Keep these files up to date** — as your architecture evolves, update `CLAUDE.md` and the relevant instruction files. Stale context is worse than no context.
