---
mode: 'agent'
description: 'Run a structured code review on any file — language-agnostic'
---

# Code Review

> **Claude Code usage:** Reference with `@prompts/code-review.prompt.md` and include the file(s) to review, e.g. `@prompts/code-review.prompt.md @src/order_service.py`.
> For deeper, stack-specific checks use a language-specific variant:
> `code-review-dotnet.prompt.md` · `code-review-java.prompt.md` · `code-review-react.prompt.md` · `code-review-python.prompt.md`

Perform a structured code review focused on correctness, architecture compliance, and security. Apply the idioms and conventions of whatever language and framework the code uses.

> **Scope:** The checklist below covers the _minimum_ concerns to verify. Do not limit your review to these items — raise any issue you find, regardless of whether it appears in the list.

## Review Checklist

### Architecture & Design

- [ ] **Layer violations** — Is any infrastructure concern (DB, HTTP client, queue) used directly in a layer where it doesn't belong?
- [ ] **Component thickness** — Does this unit do more than one thing? Should any logic be extracted?
- [ ] **Dependency direction** — Are dependencies injected via abstraction rather than concrete types?
- [ ] **Single responsibility** — Does each function/method do one clearly defined thing?
- [ ] **Configuration** — Are environment-specific values read from config/env vars, not hardcoded?

### Code Quality

- [ ] **Null / nil safety** — Are nullable or optional values checked before use?
- [ ] **Async correctness** — Is async/await used correctly? Any blocking calls inside async code?
- [ ] **Error handling** — Are errors caught at the right level? Are exceptions silently swallowed?
- [ ] **Naming** — Do names follow the conventions of the language and existing codebase?
- [ ] **Dead code** — Are there unused variables, imports, parameters, or unreachable branches?

### Data Access

- [ ] **Query safety** — Is any query built with string concatenation from user input?
- [ ] **N+1 queries** — Are related records fetched in loops instead of a single query?
- [ ] **Unbounded results** — Are queries missing pagination or limits on large result sets?
- [ ] **Transaction scope** — Are writes that must succeed together wrapped in a transaction?

### Security

- [ ] **Injection** — Is user input concatenated into SQL, shell commands, HTML, or template strings?
- [ ] **Sensitive data logged** — Are PII, tokens, passwords, or keys written to logs?
- [ ] **Hardcoded secrets** — Any credentials or API keys in source?
- [ ] **Input validation** — Is all user input validated at the system boundary before use?
- [ ] **Error leakage** — Could an unhandled exception expose internal details to the caller?

### Testing (if test file)

- [ ] Is the system under test constructed from real/mocked dependencies — never mocked itself?
- [ ] Does each test have a clear Arrange / Act / Assert structure?
- [ ] Are edge cases and exception paths covered?
- [ ] Are parameterized tests used for logic that varies across inputs?

## Output Format

For each issue found, report:

- **Severity**: Critical / Major / Minor / Suggestion
- **File + Line**: Reference to the specific code
- **Issue**: Clear description of the problem
- **Recommendation**: Concrete fix or improved code snippet

## Code to Review

Include the file(s) to review alongside this prompt:

```
@prompts/code-review.prompt.md @src/order_service.py
```

Or describe what to focus on if reviewing a specific concern rather than a full file.
