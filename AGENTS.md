# AGENTS.md — AI Agent Configuration Overview

This file documents all agent configuration files in this repository and explains how each one is used.

---

## What Are These Files For?

When working with AI coding agents (Claude Code, Claude VS Code extension), the quality of results improves significantly when the agent is given **persistent context** about your project. Without it, the agent defaults to generic patterns that may not match your architecture, naming conventions, or tech stack.

This repository provides a set of files that feed the right context to Claude — automatically on session start, or on demand during a session.

---

## File Inventory

### Core Memory File

| File | Consumed By | When |
|---|---|---|
| [`CLAUDE.md`](./CLAUDE.md) | Claude Code CLI + Claude VS Code extension | Automatically at session start |

### Detailed Context Files (On Demand)

These files extend `CLAUDE.md` with deeper, domain-specific rules. Reference them in a session when you're working in that area.

| File | Covers | How to Reference |
|---|---|---|
| [`instructions/csharp.instructions.md`](./instructions/csharp.instructions.md) | C# naming, async, nullability, patterns | `@instructions/csharp.instructions.md` |
| [`instructions/aspnetcore.instructions.md`](./instructions/aspnetcore.instructions.md) | Controllers, routing, middleware, error handling | `@instructions/aspnetcore.instructions.md` |
| [`instructions/fluentvalidation.instructions.md`](./instructions/fluentvalidation.instructions.md) | Validator structure, rules, registration | `@instructions/fluentvalidation.instructions.md` |
| [`instructions/sqlserver.instructions.md`](./instructions/sqlserver.instructions.md) | SQL types, parameterization, NOLOCK, indexes | `@instructions/sqlserver.instructions.md` |
| [`instructions/entityframework.instructions.md`](./instructions/entityframework.instructions.md) | EF Core, repository pattern, migrations | `@instructions/entityframework.instructions.md` |
| [`instructions/dynamodb.instructions.md`](./instructions/dynamodb.instructions.md) | DynamoDB key design, queries, GSIs | `@instructions/dynamodb.instructions.md` |
| [`instructions/aws.instructions.md`](./instructions/aws.instructions.md) | S3, SQS, SNS patterns and conventions | `@instructions/aws.instructions.md` |
| [`instructions/java.instructions.md`](./instructions/java.instructions.md) | Java 21, naming, records, streams, Spring DI | `@instructions/java.instructions.md` |
| [`instructions/python.instructions.md`](./instructions/python.instructions.md) | Python 3.11+, type hints, Pydantic, async, pytest | `@instructions/python.instructions.md` |
| [`instructions/go.instructions.md`](./instructions/go.instructions.md) | Go conventions, errors, interfaces, context, goroutines | `@instructions/go.instructions.md` |
| [`instructions/react.instructions.md`](./instructions/react.instructions.md) | React 18+, TypeScript, hooks, state, TanStack Query | `@instructions/react.instructions.md` |
| [`instructions/sqlite.instructions.md`](./instructions/sqlite.instructions.md) | SQLite pragmas, WAL mode, types, migrations | `@instructions/sqlite.instructions.md` |
| [`instructions/postgres.instructions.md`](./instructions/postgres.instructions.md) | PostgreSQL types, indexes, transactions, security | `@instructions/postgres.instructions.md` |
| [`instructions/mongodb.instructions.md`](./instructions/mongodb.instructions.md) | MongoDB schema design, indexes, aggregation, transactions | `@instructions/mongodb.instructions.md` |

### Reusable Prompt Files (On Demand)

Pre-written, opinionated task prompts. Reference them in Claude Code or paste them into chat, then fill in the task-specific details at the bottom of each file.

| File | Purpose |
|---|---|
| [`prompts/scaffold-vertical-slice.prompt.md`](./prompts/scaffold-vertical-slice.prompt.md) | Scaffold the full stack for a feature in one pass |
| [`prompts/scaffold-ef-entity.prompt.md`](./prompts/scaffold-ef-entity.prompt.md) | Scaffold an EF Core entity + Fluent config |
| [`prompts/scaffold-repository.prompt.md`](./prompts/scaffold-repository.prompt.md) | Scaffold a repository interface + implementation |
| [`prompts/write-sql-migration.prompt.md`](./prompts/write-sql-migration.prompt.md) | Generate an EF Core migration script |
| [`prompts/write-dynamo-query.prompt.md`](./prompts/write-dynamo-query.prompt.md) | Write a type-safe DynamoDB query |
| [`prompts/generate-unit-tests.prompt.md`](./prompts/generate-unit-tests.prompt.md) | Generate xUnit unit tests |
| [`prompts/code-review.prompt.md`](./prompts/code-review.prompt.md) | Run a .NET-focused code review |

### Documentation

| File | Purpose |
|---|---|
| [`docs/agent-optimization-summary.md`](./docs/agent-optimization-summary.md) | Deep-dive on the strategy behind all these files |
| [`docs/common-agent-mistakes.md`](./docs/common-agent-mistakes.md) | Living log of patterns the agent gets wrong — add entries as you find them |
| [`README.md`](./README.md) | Getting started guide |

---

## File Priority & Usage Hierarchy

```
CLAUDE.md                          ← Auto-loaded every Claude Code session (highest trust)
instructions/*.instructions.md     ← Reference on demand for focused domain work
prompts/*.prompt.md                ← Reference on demand for reusable task execution
```

---

## Key Principles

1. **`CLAUDE.md` is the always-on baseline** — it covers the full stack at a summary level and is automatically loaded every session.
2. **Instruction files are on-demand depth** — pull them in when you're doing focused work in a specific area (EF migrations, DynamoDB queries, etc.).
3. **Prompts are reusable task macros** — each prompt bakes in your architecture standards so you only need to provide the task-specific inputs.
4. **Keep these files up to date** — as your architecture evolves, update `CLAUDE.md` and the relevant instruction files. Stale context is worse than no context.
