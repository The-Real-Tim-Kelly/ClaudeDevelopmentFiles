---
applyTo: '**'
---

# Observe-First Instructions

> **Claude Code:** Combine this file with any other instruction file when working in an **existing codebase** that may have its own established conventions:
>
> ```
> @instructions/observe-first.instructions.md
> @instructions/csharp.instructions.md
> Help me add a new service to this codebase.
> ```

---

## Core Directive

Before applying any standard from a companion instruction file, **scan the existing code first**. If a clear, consistent pattern is already in use, follow it — even if it differs from the companion file's recommendation. The companion file is a reference and a default, not a mandate.

The goal is to produce code that looks like it belongs in **this** codebase, not code that looks like it came from a template.

---

## What to Look For Before Writing Any Code

When you receive a task, spend a moment observing:

1. **Naming** — What do existing classes, methods, variables, and files look like? Abbreviations? Prefixes? Suffixes? Follow exactly what's there.
2. **File & folder structure** — Where do similar things live? Match it.
3. **Error handling style** — Custom exceptions? Result types? Raw try/catch? Follow the pattern in use.
4. **Dependency injection** — Constructor injection? Property injection? Service locator? Match what exists.
5. **Async patterns** — Are all methods async? Mixed? Is `CancellationToken` in use? Follow the existing approach.
6. **Logging** — What logger is used? How are messages structured? Match it.
7. **Comments & documentation** — Are there XML docs? Inline comments? No comments at all? Match the existing level.
8. **Test structure** — What's the naming pattern? What mocking library? What assertion library? Follow it.

---

## Priority Rules

| Category                                                    | Priority                                                   |
| ----------------------------------------------------------- | ---------------------------------------------------------- |
| **Existing codebase patterns** (naming, structure, style)   | **Highest** — always follow what's there                   |
| **Companion instruction file** (standards & best practices) | Default — apply when no existing pattern is observable     |
| **Security rules** (see below)                              | **Non-negotiable** — apply regardless of existing patterns |
| **Correctness rules** (see below)                           | **Non-negotiable** — apply regardless of existing patterns |

---

## Non-Negotiable Rules — Always Apply

These rules apply regardless of what existing code does. If existing code violates them, do not replicate the violation — but also do not refactor existing code unless that's explicitly part of the task.

### Security (never compromise)

- Never build SQL strings from user input — use parameterized queries
- Never log passwords, tokens, API keys, or PII
- Never hardcode credentials or secrets in source code
- Never use `eval()`, `exec()`, or equivalent with untrusted input
- Validate all inputs at system boundaries

### Correctness (never compromise)

- Do not introduce race conditions or thread-safety issues
- Do not silently swallow exceptions
- Do not ignore or discard `CancellationToken` / `Context` / cancellation signals when they are passed in
- Do not introduce blocking calls inside async/non-blocking code paths
- Do not hard delete records where a soft-delete pattern is already in use in the same table/collection

---

## How to Handle Conflicts

When you observe a pattern that conflicts with the companion instruction file, use this logic:

| Situation                                                                        | What to do                                                                             |
| -------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Existing code has a clear, consistent style that differs from the companion file | Follow existing code; note the deviation in a brief inline comment if it's non-obvious |
| Existing code is **inconsistent** (mixed patterns)                               | Apply the companion file's standard and note that you're normalizing                   |
| Existing code violates a non-negotiable rule                                     | Apply the correct approach for new code; do not replicate the violation                |
| No existing code to observe (new file, new project)                              | Apply the companion instruction file's standards in full                               |

---

## Example Usage in Claude Code

```
@instructions/observe-first.instructions.md
@instructions/python.instructions.md

I need to add a new service class to handle order notifications.
The existing services are in src/services/. Please check how they're structured before writing anything.
```

```
@instructions/observe-first.instructions.md
@instructions/react.instructions.md

Add a new OrderSummaryCard component. Look at the existing components in src/components/ first to match the style.
```
