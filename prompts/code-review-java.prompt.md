---
mode: 'agent'
description: 'Run a structured code review on a Java / Spring Boot file'
---

# Code Review — Java

> **Claude Code usage:** Reference with `@prompts/code-review-java.prompt.md` and include the file(s) to review, e.g. `@prompts/code-review-java.prompt.md @src/main/java/com/example/OrderService.java`.

Perform a structured code review focused on correctness, architecture compliance, security, and Java/Spring best practices.

> **Scope:** The checklist below covers the _minimum_ concerns to verify. Do not limit your review to these items — raise any issue you find, regardless of whether it appears in the list.

## Review Checklist

### Architecture & Design

- [ ] **Layer violations** — Does a controller access a repository directly, bypassing the service layer?
- [ ] **Controller thickness** — Does the controller contain business logic instead of delegating to a service?
- [ ] **DI via interface** — Are dependencies injected through interfaces, not concrete classes?
- [ ] **Single responsibility** — Does each class/method do one clearly defined thing?
- [ ] **`@Value` vs `@ConfigurationProperties`** — Is `@Value` used for groups of related config that should be a typed properties class?

### Java Quality

- [ ] **`Optional` misuse** — Is `Optional.get()` called without `isPresent()` check, or `Optional` used as a method parameter/field?
- [ ] **Checked exceptions** — Are checked exceptions swallowed silently or wrapped without preserving the cause?
- [ ] **Mutable default arguments** — Any shared mutable state being used as a default value?
- [ ] **`var` overuse** — Is `var` obscuring a non-obvious type that hurts readability?
- [ ] **Naming** — PascalCase classes, camelCase methods/fields, SCREAMING_SNAKE_CASE constants?
- [ ] **Records / immutability** — Are DTOs and value objects using `record` (Java 16+) where appropriate?

### Spring / JPA

- [ ] **`@Transactional` placement** — Is it on the service layer, not the controller or repository?
- [ ] **N+1 queries** — Are `@OneToMany` / `@ManyToMany` relations triggering lazy-load loops?
- [ ] **Fetch strategy** — Is `FetchType.EAGER` used where it will cause unnecessary joins?
- [ ] **Session scope** — Is a JPA `EntityManager` or `Session` being used outside a managed transaction?
- [ ] **Native queries** — Is any native SQL parameterized? No string concatenation into JPQL/native SQL?
- [ ] **Repository return types** — Are `List` returns paginated for potentially large result sets?

### Security

- [ ] **SQL / JPQL injection** — Is any query built with string concatenation from user input?
- [ ] **Sensitive data logged** — Are PII, tokens, passwords, or keys written to logs?
- [ ] **Hardcoded secrets** — Any credentials or API keys in source?
- [ ] **Input validation** — Is Bean Validation (`@Valid`, `@NotNull`, etc.) applied at the controller boundary?
- [ ] **Deserialization** — Is `ObjectInputStream`, `readObject`, or any unsafe deserialization in use?

### Testing (if test file)

- [ ] Is the SUT constructed from real/mocked dependencies — never mocked itself?
- [ ] Are Spring slice tests (`@WebMvcTest`, `@DataJpaTest`) used instead of full `@SpringBootTest` where appropriate?
- [ ] Are mocks set up with `@ExtendWith(MockitoExtension.class)` / `@MockBean` appropriately?
- [ ] Are AssertJ assertions (`assertThat(...)`) used consistently?
- [ ] Are edge cases and exception paths covered?

## Output Format

For each issue found, report:

- **Severity**: Critical / Major / Minor / Suggestion
- **File + Line**: Reference to the specific code
- **Issue**: Clear description of the problem
- **Recommendation**: Concrete fix or improved code snippet

## Code to Review

Include the file(s) to review alongside this prompt:

```
@prompts/code-review-java.prompt.md @src/main/java/com/example/service/OrderService.java
```
