---
mode: 'agent'
description: 'Run a structured code review on a Python file'
---

# Code Review — Python

> **Claude Code usage:** Reference with `@prompts/code-review-python.prompt.md` and include the file(s) to review, e.g. `@prompts/code-review-python.prompt.md @src/services/order_service.py`.

Perform a structured code review focused on correctness, architecture compliance, security, and Python best practices.

> **Scope:** The checklist below covers the _minimum_ concerns to verify. Do not limit your review to these items — raise any issue you find, regardless of whether it appears in the list.

## Review Checklist

### Architecture & Design

- [ ] **Layer violations** — Does a route handler contain business logic that belongs in a service?
- [ ] **DI / testability** — Are dependencies hard-instantiated inside functions, making them untestable?
- [ ] **Single responsibility** — Does each function/class do one clearly defined thing?
- [ ] **Global state** — Is mutable module-level state used where it could cause cross-request contamination?
- [ ] **Config access** — Are environment variables read inline (`os.environ`) instead of through a typed settings class?

### Python Quality

- [ ] **Type hints** — Are all function signatures annotated (parameters and return type)?
- [ ] **Mutable default arguments** — Any `def f(items=[])` or `def f(data={})` patterns?
- [ ] **Broad exception handling** — Is `except Exception` or bare `except:` swallowing errors silently?
- [ ] **`None` checks** — Are `Optional` types handled before use? Is `typing.Optional` or `X | None` used correctly?
- [ ] **Comprehension clarity** — Are nested comprehensions complex enough to warrant a loop instead?
- [ ] **f-string vs `%` / `.format()`** — Is the string formatting style consistent with the codebase?

### Async

- [ ] **Blocking I/O in async context** — Are any synchronous blocking calls (`requests.get`, file I/O) made inside `async def` functions?
- [ ] **Missing `await`** — Are coroutines called without `await`, silently doing nothing?
- [ ] **`asyncio.gather` vs sequential `await`** — Are independent async calls awaited sequentially when they could run concurrently?
- [ ] **Thread safety** — Is shared mutable state accessed across coroutines without a lock?

### SQLAlchemy / Database

- [ ] **Session management** — Is the session closed/returned in all paths, including exceptions?
- [ ] **Raw SQL safety** — Is any raw SQL parameterized? No f-string or `.format()` into a SQL string?
- [ ] **N+1 queries** — Are related objects accessed in a loop without eager loading?
- [ ] **Unbounded queries** — Are queries missing `.limit()` on potentially large result sets?

### Security

- [ ] **SQL injection** — Is user input concatenated directly into a SQL string?
- [ ] **`eval` / `exec`** — Are `eval`, `exec`, or `compile` called with any user-controlled input?
- [ ] **Pickle deserialization** — Is `pickle.loads` called on untrusted data?
- [ ] **Sensitive data logged** — Are PII, tokens, or credentials written to logs?
- [ ] **Hardcoded secrets** — Any API keys, passwords, or connection strings in source?
- [ ] **Path traversal** — Is user input used to construct file paths without sanitization?

### Testing (if test file)

- [ ] Are fixtures scoped appropriately (`function`, `module`, `session`)?
- [ ] Is `unittest.mock.patch` used at the correct import path (where the name is used, not defined)?
- [ ] Are edge cases and exception paths covered?
- [ ] Are `pytest.raises` context managers used for expected exceptions?
- [ ] Are async tests marked with `@pytest.mark.asyncio`?

## Output Format

For each issue found, report:

- **Severity**: Critical / Major / Minor / Suggestion
- **File + Line**: Reference to the specific code
- **Issue**: Clear description of the problem
- **Recommendation**: Concrete fix or improved code snippet

## Code to Review

Include the file(s) to review alongside this prompt:

```
@prompts/code-review-python.prompt.md @src/services/order_service.py
```
