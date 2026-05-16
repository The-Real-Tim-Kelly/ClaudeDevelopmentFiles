# Code Review

> **Claude Code usage:** Reference this with `@prompts/code-review.prompt.md` and include the file(s) to review in the same message, e.g. `@prompts/code-review.prompt.md @src/MyService.cs`.

Perform a structured code review focused on correctness, architecture compliance, security, and .NET best practices.

## Review Checklist

### Architecture & Design
- [ ] **Layer violations** — Is EF/DynamoDB context injected anywhere outside of a repository?
- [ ] **Controller thickness** — Does the controller contain business logic that belongs in a service?
- [ ] **Interface dependency** — Are all dependencies injected via interface, not concrete type?
- [ ] **Single responsibility** — Does each class/method do one thing?
- [ ] **Configuration access** — Is `IConfiguration` used directly in a service (should use `IOptions<T>`)?

### C# Quality
- [ ] **Null safety** — Are nullable warnings handled properly without `!` suppression?
- [ ] **Async correctness** — Any `.Result` or `.Wait()` calls? Missing `await`? Fire-and-forget without handling?
- [ ] **CancellationToken** — Is `ct` propagated to all downstream async calls?
- [ ] **Naming** — Are conventions (PascalCase, camelCase, `_camelCase`, `Async` suffix) followed?
- [ ] **LINQ** — Any N+1 risks from iterating an IQueryable after breaking out of the query?

### Entity Framework
- [ ] **Async methods** — Any synchronous EF calls (`.ToList()`, `.FirstOrDefault()`)?
- [ ] **Tracking** — Are read-only queries using `.AsNoTracking()`?
- [ ] **Eager loading** — Are navigation properties always `.Include()`d before access?
- [ ] **Raw SQL** — Is any raw SQL parameterized? No string interpolation into SQL?
- [ ] **SaveChanges scope** — Is `SaveChangesAsync` called at the right level (repository, not service)?

### DynamoDB
- [ ] **Table scan** — Is `ScanAsync` called anywhere? (Should always be a query)
- [ ] **Hardcoded table names** — Are table/index names from config, not literals?
- [ ] **Access pattern comment** — Is there a comment above each query explaining its access pattern?
- [ ] **Condition expressions** — Are writes protected against overwriting with condition expressions?
- [ ] **Error handling** — Is `ConditionalCheckFailedException` caught and handled appropriately?

### Security
- [ ] **SQL injection** — Is any SQL built with string concatenation or interpolation?
- [ ] **Logging sensitive data** — Are PII, tokens, or credentials logged anywhere?
- [ ] **Secrets in code** — Are any credentials, API keys, or connection strings hardcoded?
- [ ] **Input validation** — Is all user input validated before use (FluentValidation at API boundary)?
- [ ] **Unhandled exceptions** — Could any exception leak internal details to the HTTP response?

### Testing Coverage (if test file)
- [ ] Is the SUT constructed from mocks, not mocked itself?
- [ ] Does each test have a clear Arrange / Act / Assert structure?
- [ ] Are edge cases and exception paths tested?
- [ ] Are `[Theory]` tests used for boundary/parameterized cases?

## Output Format

For each issue found, report:
- **Severity**: Critical / Major / Minor / Suggestion
- **File + Line**: Reference to the specific code
- **Issue**: Clear description of the problem
- **Recommendation**: Concrete fix or improved code snippet

## Code to Review

**Include the file(s) to review alongside this prompt**, for example:

```
@prompts/code-review.prompt.md @src/MyApp.Infrastructure/Repositories/OrderRepository.cs
```

Or describe what to focus on if reviewing a specific concern rather than a full file.
