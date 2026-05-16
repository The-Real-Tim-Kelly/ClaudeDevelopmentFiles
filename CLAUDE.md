# CLAUDE.md — Project Memory for Claude Code

This file is automatically read by Claude Code at the start of every session.
**Copy this file to the root of your project and fill in every section below.**
The more accurately this reflects your actual project, the better the agent will perform.

Delete placeholder text and sections that don't apply to your stack.

---

## Project Overview

<!-- One or two sentences: what does this application do? Who uses it? -->
<!-- Example: "A B2B SaaS platform for managing field service work orders. Used by operations managers and field technicians." -->

**Description:** [TODO — describe the application]

**Type:** [e.g., REST API / Web App / CLI tool / Background service / Mobile app]

---

## Tech Stack

<!-- List every significant technology. Be specific about versions where they matter. -->
<!-- Remove lines that don't apply; add lines for things not listed. -->

- **Language(s):** [e.g., TypeScript 5, Python 3.12, C# .NET 9, Go 1.23, Java 21]
- **Runtime / Framework:** [e.g., Node.js 22, ASP.NET Core, Spring Boot 3, FastAPI]
- **Frontend:** [e.g., React 18 + Vite, Next.js 14, None]
- **Database(s):** [e.g., PostgreSQL 16, SQL Server 2022, MongoDB 7, SQLite, DynamoDB]
- **ORM / Data Access:** [e.g., Entity Framework Core, Prisma, SQLAlchemy, GORM]
- **Test Framework:** [e.g., xUnit + Moq, pytest, Jest, JUnit 5]
- **Cloud / Infrastructure:** [e.g., AWS, Azure, GCP, self-hosted]
- **Key Libraries:** [e.g., FluentValidation, TanStack Query, Pydantic, Lombok]

---

## Project Structure

<!-- Show the top-level folder layout with a brief annotation for each folder. -->
<!-- This is the single most useful thing for the agent — don't skip it. -->

```
[TODO — paste or describe your folder structure here]

Example:
src/
  api/           # HTTP handlers and routing
  domain/        # Core business logic and entities
  infra/         # Database, external services
  shared/        # Shared utilities, constants, types
tests/           # Unit and integration tests
```

---

## Naming Conventions

<!-- The agent will default to conventions for your language — only override what differs from standard. -->

- **Files:** [e.g., kebab-case.ts / PascalCase.cs / snake_case.py]
- **Classes / Types:** [e.g., PascalCase]
- **Functions / Methods:** [e.g., camelCase / snake_case]
- **Variables:** [e.g., camelCase]
- **Database tables / columns:** [e.g., snake_case, plural table names]
- **Constants:** [e.g., SCREAMING_SNAKE_CASE]
- **Test files:** [e.g., `*.test.ts` colocated with source / `tests/` mirror structure]

---

## Architecture & Patterns

<!-- Describe the patterns in use. The agent needs to know these to write consistent code. -->

**Layering / structure:**
[e.g., "Clean Architecture — Domain → Application → Infrastructure → API. No infrastructure references in Domain or Application layers."
or "Feature folders: each feature owns its own handler, service, and repository."
or "MVC — thin controllers, business logic in services, repositories for data access."]

**Data access:**
[e.g., "Repository pattern — all DB access through interfaces, never raw ORM in controllers or services."
or "Direct ORM queries in service layer — no repository abstraction."
or "CQRS with MediatR — commands and queries separated."]

**Error handling:**
[e.g., "Exceptions bubble up and are caught by a global handler returning RFC 9457 ProblemDetails."
or "Result<T> / Either pattern — no exceptions for expected failures."
or "Errors returned as values; only panic for truly unrecoverable states."]

**Async:**
[e.g., "Async end-to-end — no sync-over-async. All I/O must be awaited."
or "Sync codebase — async only at the HTTP boundary."]

---

## Testing Conventions

<!-- Describe test structure, naming, and tooling. -->

- **Test location:** [e.g., colocated `*.test.ts` files / separate `tests/` mirror / `*Tests.cs` in project]
- **Test naming:** [e.g., `methodName_scenario_expectedResult` / `test_method_when_x_then_y` / `"should do X when Y"`]
- **Mocking:** [e.g., Moq / Jest mocks / unittest.mock / testify]
- **Integration tests:** [e.g., against in-memory DB / Docker Compose / real test DB]
- **Assertions:** [e.g., FluentAssertions / built-in assert / assertj]

---

## Key Conventions & Rules

<!-- Project-specific rules that override or extend language defaults. -->
<!-- Be specific — vague rules like "write clean code" are useless here. -->

- [e.g., "All database queries must be paginated — no unbounded fetches."]
- [e.g., "Every public API endpoint requires authentication unless marked [AllowAnonymous]."]
- [e.g., "Secrets must come from environment variables or secrets manager — never hardcoded."]
- [e.g., "All timestamps stored and compared in UTC."]
- [e.g., "Soft delete only — no hard deletes on user-owned data."]
- [e.g., "Feature flags live in config — no if/else blocks for features in domain logic."]

---

## Common Commands

<!-- The commands the agent will need to run locally. -->

```bash
# Install dependencies
[TODO]

# Run the application
[TODO]

# Run tests
[TODO]

# Run linter / formatter
[TODO]

# Database migrations (if applicable)
[TODO]
```

---

## Important Reminders for the Agent

<!-- Rules you've had to correct the agent on before. Add to this list over time. -->
<!-- See also: docs/common-agent-mistakes.md for a running log. -->

- Validate all external inputs at the API / service boundary — never trust request data directly.
- Keep secrets out of code — use environment variables, config files excluded from source control, or a secrets manager.
- [Add your own reminders here as you work with the agent and notice repeated mistakes.]
