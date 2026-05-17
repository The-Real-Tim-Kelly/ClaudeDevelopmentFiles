# Copilot Instructions

## Observe First

Before applying any convention from an instruction file, scan the existing codebase.
If a clear, consistent pattern is already in use, follow it — even if it differs from
the referenced instruction files. Consistency with the codebase takes precedence.

## Security

- Validate all external inputs at the system boundary — never trust request data directly
- No hardcoded secrets — use environment variables or a secrets manager
- Use parameterized queries — never concatenate user input into SQL or shell commands
- All timestamps stored and compared in UTC

## Code Quality

- Prefer simple, readable solutions over clever ones
- Don't add error handling for scenarios that cannot happen
- Don't add docstrings, comments, or type annotations to code you didn't touch
- Keep methods focused and small

## Architecture

- Match the layering and patterns already in the project
- No infrastructure dependencies in core/domain layers
- Controllers stay thin — business logic belongs in services

## Testing

- Test edge cases and failure paths, not just the happy path
- Never mock the system under test
- One assertion concept per test
