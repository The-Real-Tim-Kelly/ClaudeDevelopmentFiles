---
mode: 'agent'
description: 'Run a structured code review on a .NET / ASP.NET Core / EF Core file'
---

# Code Review — .NET

> **Claude Code usage:** Reference with `@prompts/code-review-dotnet.prompt.md` and include the file(s) to review, e.g. `@prompts/code-review-dotnet.prompt.md @src/MyService.cs`.

Perform a structured code review focused on correctness, architecture compliance, security, and .NET best practices.

> **Scope:** The checklist below covers the _minimum_ concerns to verify. Do not limit your review to these items — raise any issue you find, regardless of whether it appears in the list.

## Review Checklist

### Architecture & Design

- [ ] **Layer violations** — Is EF context or any infrastructure concern injected outside of a repository?
- [ ] **Controller thickness** — Does the controller contain business logic that belongs in a service?
- [ ] **Interface dependency** — Are all dependencies injected via interface, not concrete type?
- [ ] **Single responsibility** — Does each class/method do one clearly defined thing?
- [ ] **Configuration access** — Is `IConfiguration` used directly in a service (should use `IOptions<T>`)?

### C# Quality

- [ ] **Null safety** — Are nullable warnings handled properly without `!` suppression?
- [ ] **Async correctness** — Any `.Result` or `.Wait()` calls? Missing `await`? Unhandled fire-and-forget?
- [ ] **CancellationToken** — Is `ct` propagated to all downstream async calls?
- [ ] **Naming** — PascalCase members, camelCase locals, `_camelCase` private fields, `Async` suffix on async methods?
- [ ] **LINQ** — Any N+1 risk from materializing an `IQueryable` mid-query, then iterating?

### Entity Framework Core

- [ ] **Async methods** — Any synchronous EF calls (`.ToList()`, `.FirstOrDefault()` without `Async`)?
- [ ] **Tracking** — Are read-only queries using `.AsNoTracking()`?
- [ ] **Eager loading** — Are navigation properties always `.Include()`d before access?
- [ ] **Raw SQL** — Is any raw SQL parameterized? No string interpolation into `FromSqlRaw`?
- [ ] **SaveChanges scope** — Is `SaveChangesAsync` called at the right layer (repository, not service)?

### Security

- [ ] **SQL injection** — Is any SQL built with string concatenation or interpolation?
- [ ] **Sensitive data logged** — Are PII, tokens, or credentials written to logs?
- [ ] **Hardcoded secrets** — Any credentials, API keys, or connection strings in source?
- [ ] **Input validation** — Is all user input validated before use (FluentValidation at API boundary)?
- [ ] **Exception leakage** — Could an unhandled exception expose internal details to the HTTP response?

### Testing (if test file)

- [ ] Is the SUT constructed from real/mocked dependencies — never mocked itself?
- [ ] Does each test have a clear Arrange / Act / Assert structure?
- [ ] Are edge cases and exception paths covered?
- [ ] Are `[Theory]` + `[InlineData]` / `[MemberData]` used for parameterized cases?

## Output Format

For each issue found, report:

- **Severity**: Critical / Major / Minor / Suggestion
- **File + Line**: Reference to the specific code
- **Issue**: Clear description of the problem
- **Recommendation**: Concrete fix or improved code snippet

## Code to Review

Include the file(s) to review alongside this prompt:

```
@prompts/code-review-dotnet.prompt.md @src/MyApp.Infrastructure/Repositories/OrderRepository.cs
```
