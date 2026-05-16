# Agent Optimization Strategy — .NET C# with EF Core, SQL Server & DynamoDB

This document explains the philosophy behind the agent configuration files in this repository, what each type of file does, and how they work together with Claude Code.

---

## The Core Problem

AI coding agents are general-purpose by default. When Claude Code opens a .NET project, it doesn't know:

- That you use the repository pattern and `DbContext` must never leak into services
- That your DynamoDB table names come from `IOptions<T>`, not hardcoded strings
- That migrations must be named `YYYYMMDD_ShortDescription`
- That every DynamoDB query needs an access-pattern comment above it

Without this context, the agent makes plausible but wrong suggestions — the code compiles but violates your architecture.

The solution is **persisted, structured context** delivered to Claude Code in the format it expects.

---

## File Types Explained

### 1. `CLAUDE.md` — Claude Code Project Memory

Claude Code automatically reads `CLAUDE.md` at the start of every session when it's located in the project root. This is the single most impactful file — it's the always-on baseline.

**What to put here:**
- Tech stack and project structure overview
- Coding conventions (naming, patterns, idioms)
- Architecture rules that the agent must never violate
- Common CLI commands (`dotnet ef migrations add`, etc.)
- Reminders for patterns the agent frequently gets wrong

**Key property:** Loaded *automatically* — you never have to paste context manually.

---

### 2. `instructions/*.instructions.md` — On-Demand Domain Context

These are detailed, domain-scoped rule sets that extend `CLAUDE.md`. They exist as separate files rather than one giant `CLAUDE.md` because loading all context all the time adds noise. Pull in only what's relevant to the task at hand.

**How to use:**
```
@instructions/entityframework.instructions.md
I need to add a soft-delete entity for products with an EF Core config.
```

**Why scope matters:** A DynamoDB-specific rule like "never do a table scan" is irrelevant noise when you're fixing a C# naming issue. Scoped files keep context clean and targeted.

| File | Domain | When to Reference |
|---|---|---|
| `csharp.instructions.md` | All C# | General C# work, code reviews |
| `sqlserver.instructions.md` | SQL scripts | Writing or reviewing `.sql` files |
| `entityframework.instructions.md` | EF Core | Entities, repositories, migrations |
| `dynamodb.instructions.md` | DynamoDB | DynamoDB models, queries, GSI design |

---

### 3. `prompts/*.prompt.md` — Reusable Task Prompts

Prompt files are saved, opinionated task definitions for your most repeated agent workflows. Think of them as macros — the standards are pre-baked, and you fill in only the task-specific details.

**How to use in Claude Code:**
```
@prompts/scaffold-repository.prompt.md
Entity: Order
Extra queries: GetByCustomerIdAsync, GetPendingOrdersAsync
Soft delete: yes
```

Or open the prompt file, fill in the **"Fill in before running"** section at the bottom, then paste the whole thing into the chat.

**The advantage:** Instead of typing a full, context-rich prompt every time, you reference the file and add only what's unique to this task.

| Prompt | When to Use |
|---|---|
| `scaffold-ef-entity.prompt.md` | Creating a new domain entity with EF config |
| `scaffold-repository.prompt.md` | Creating a new repository for an entity |
| `write-sql-migration.prompt.md` | Planning or generating a schema migration |
| `write-dynamo-query.prompt.md` | Writing a new DynamoDB query method |
| `generate-unit-tests.prompt.md` | Creating test coverage for a class |
| `code-review.prompt.md` | Reviewing code against architecture rules |

---

## How the Files Work Together

```
Claude Code / Claude VS Code extension
  └── reads CLAUDE.md automatically on every session
       └── full stack context available from line 1

  └── you reference instructions/*.instructions.md on demand
       └── deep domain rules when doing focused work

  └── you reference prompts/*.prompt.md on demand
       └── consistent, standards-baked task execution
```

---

## Maintenance Guide

These files are only as useful as they are current. When your project evolves:

| Change | Update |
|---|---|
| New migration naming convention | `CLAUDE.md` + `entityframework.instructions.md` |
| New DynamoDB table / GSI pattern | `CLAUDE.md` + `dynamodb.instructions.md` |
| New architectural layer added | `CLAUDE.md` + `csharp.instructions.md` |
| New common task emerges | Add a new `prompts/*.prompt.md` |
| Architecture rule changed | Update both `CLAUDE.md` and the relevant `.instructions.md` |

---

## Quick-Start Checklist

When copying these files into a new .NET project:

- [ ] Copy `CLAUDE.md` to the solution root
- [ ] Update the *Project Structure* section in `CLAUDE.md` to match your actual layout
- [ ] Update DynamoDB table name config keys in `dynamodb.instructions.md` to match your `DynamoDbOptions`
- [ ] Add your actual project's build, test, and migration commands to `CLAUDE.md`
- [ ] Copy `instructions/` and `prompts/` folders into the project (or keep them here and reference by path)
- [ ] Add team-specific prompt files for your most repeated agent tasks
