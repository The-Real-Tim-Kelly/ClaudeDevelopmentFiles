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
| [`instructions/sqlserver.instructions.md`](./instructions/sqlserver.instructions.md) | SQL types, parameterization, NOLOCK, indexes | `@instructions/sqlserver.instructions.md` |
| [`instructions/entityframework.instructions.md`](./instructions/entityframework.instructions.md) | EF Core, repository pattern, migrations | `@instructions/entityframework.instructions.md` |
| [`instructions/dynamodb.instructions.md`](./instructions/dynamodb.instructions.md) | DynamoDB key design, queries, GSIs | `@instructions/dynamodb.instructions.md` |

### Reusable Prompt Files (On Demand)

Pre-written, opinionated task prompts. Reference them in Claude Code or paste them into chat, then fill in the task-specific details at the bottom of each file.

| File | Purpose |
|---|---|
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
