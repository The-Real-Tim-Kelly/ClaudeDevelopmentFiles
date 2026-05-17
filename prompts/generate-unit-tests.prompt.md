---
mode: 'agent'
description: 'Generate unit tests for any class or module — language-agnostic'
---

# Generate Unit Tests

> **Claude Code usage:** Reference with `@prompts/generate-unit-tests.prompt.md` and include the file to test, e.g. `@prompts/generate-unit-tests.prompt.md @src/order_service.py`.
> For stack-specific conventions and templates use a language-specific variant instead:
> `generate-unit-tests-dotnet.prompt.md` · `generate-unit-tests-java.prompt.md` · `generate-unit-tests-react.prompt.md` · `generate-unit-tests-python.prompt.md`

Generate a complete, production-quality test suite for the target class or module using the testing framework and conventions already in use in this project.

> **Scope:** The scenarios listed below are a _minimum baseline_. Add any additional cases you identify as valuable — do not artificially restrict coverage to this list.

## What to Generate

1. **Test file** following the naming and location conventions already used in this project
2. **Mock / stub all external dependencies** — never mock the system under test itself
3. **At minimum**, one test per public method covering:
   - Happy path (valid input → expected output or side-effect)
   - Null / empty / missing inputs
   - Boundary values
   - Every distinct exception or error path
   - Async cancellation where applicable
4. **Parameterized tests** for any logic that branches on varying inputs
5. **Verify interactions** with dependencies where a call is required (not just that no exception is thrown)

## Test Structure

Regardless of language, follow Arrange / Act / Assert:

```
// Arrange — set up inputs, mocks, and expected values
// Act     — call the method under test
// Assert  — verify the result and any required side-effects
```

One assertion _concept_ per test. If a scenario genuinely requires multiple assertions, group only the closely related ones together.

## File and Tooling Conventions

Before generating, scan the existing test files in the project to identify:

- The test framework and assertion library in use
- The mocking library in use
- The file naming and folder structure in use
- The test method naming pattern in use

Follow whatever is already there. Do not introduce new dependencies.

## Target Class / Module

**Fill in before running:**

- **Class / module:** e.g. `OrderService`
- **Methods to test:** e.g. `createOrder`, `cancelOrder`
- **Key scenarios / edge cases:** e.g. order not found, duplicate request, payment failure
- **File:** include alongside this prompt, e.g. `@src/services/order_service.py` or `@src/OrderService.java`
