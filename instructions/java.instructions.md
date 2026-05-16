# Java Coding Instructions

> **Claude Code:** Reference this file with `@instructions/java.instructions.md` when working on Java code.

---

## Language Version

- Target **Java 21 LTS** (or 17 LTS minimum)
- Enable preview features only when a specific, documented reason exists
- Use modern language features — do not write Java 8-style code in a Java 21 project

---

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Classes, interfaces, enums, records | PascalCase | `OrderService`, `PaymentStatus` |
| Methods, local variables, parameters | camelCase | `findById`, `orderId` |
| Constants (`static final`) | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| Packages | lowercase, dot-separated | `com.myapp.domain.order` |
| Generic type parameters | Single uppercase letter, or `T`-prefixed noun | `T`, `K`, `V`, `TEntity` |

---

## Modern Java Features — Prefer These

```java
// Records for immutable data carriers / DTOs
public record CreateOrderRequest(UUID customerId, List<OrderItemRequest> items) {}

// Sealed classes for restricted type hierarchies
public sealed interface PaymentResult permits PaymentSuccess, PaymentFailure {}
public record PaymentSuccess(String transactionId) implements PaymentResult {}
public record PaymentFailure(String reason) implements PaymentResult {}

// Pattern matching switch (Java 21)
String label = switch (status) {
    case PENDING   -> "Awaiting payment";
    case SHIPPED   -> "On the way";
    case DELIVERED -> "Delivered";
    default        -> "Unknown";
};

// Pattern matching instanceof
if (result instanceof PaymentFailure failure) {
    log.warn("Payment failed: {}", failure.reason());
}

// Text blocks for multi-line strings
String sql = """
        SELECT id, email
        FROM dbo.Customer
        WHERE is_deleted = false
        """;
```

---

## Nullability

- Use **`Optional<T>`** as a method return type when a value may be absent — never return `null` from a public method
- Never pass `null` as a method argument — use `Optional.empty()` or a null-object pattern
- Annotate with `@NonNull` / `@Nullable` (from `org.springframework.lang` or `jakarta.annotation`) where intent needs documenting
- Use `Objects.requireNonNull(value, "message")` at the top of constructors for mandatory dependencies

---

## Classes & Object Design

- Prefer **immutability** — use `record` for data-only types; use `final` fields and no setters where practical
- Mark concrete classes `final` unless inheritance is intentional
- Use **interfaces** to define contracts; keep implementations package-private where possible
- Avoid `static` mutable state — it breaks testability and concurrency safety
- Keep methods short (\~20 lines); extract private helpers rather than nesting logic

---

## Collections & Streams

```java
// Prefer factory methods for small collections (immutable)
var ids = List.of(1L, 2L, 3L);
var config = Map.of("key", "value");

// Streams for transformations — avoid side effects inside stream operations
List<OrderSummary> summaries = orders.stream()
    .filter(o -> !o.isDeleted())
    .sorted(Comparator.comparing(Order::createdAt).reversed())
    .map(orderMapper::toSummary)
    .toList();   // Java 16+ — prefer over .collect(Collectors.toList())
```

---

## Exception Handling

- Use **checked exceptions** for recoverable scenarios (I/O, external calls); **unchecked** for programming errors
- Create domain-specific unchecked exceptions: `NotFoundException`, `ConflictException`
- Never swallow exceptions with an empty catch block — at minimum, log and rethrow
- Log with context: `log.error("Failed to process order {}", orderId, ex)`
- Use try-with-resources for all `Closeable` (streams, connections, readers)

---

## Dependency Injection (Spring Boot)

- Use **constructor injection** — never field injection (`@Autowired` on fields)
- Mark single-constructor classes without needing `@Autowired` (Spring infers it automatically)
- Use `@Service`, `@Repository`, `@Component` to classify beans; `@Configuration` + `@Bean` for explicit wiring
- Bind configuration with `@ConfigurationProperties` and a typed POJO — never `@Value` for multi-property config blocks:
  ```java
  @ConfigurationProperties(prefix = "dynamodb")
  public record DynamoDbProperties(String orderTableName, String region) {}
  ```

---

## Testing (JUnit 5 + Mockito)

- Test class: `<ClassName>Test`, same package as subject
- Method name: `methodName_scenario_expectedResult` or descriptive `@DisplayName`
- Use `@ExtendWith(MockitoExtension.class)` with `@Mock` and `@InjectMocks`
- Use `@ParameterizedTest` + `@MethodSource` / `@CsvSource` for data-driven tests
- Assert with **AssertJ**: `assertThat(result).isEqualTo(expected)`
- Never mock the subject under test

---

## Security

- Never concatenate user input into SQL strings — use `PreparedStatement` or JPA/repository methods
- Hash passwords with **BCrypt** (via Spring Security) — never store plain text or use MD5/SHA-1
- Log exceptions but never log passwords, tokens, or PII
- Validate all inputs at the API boundary (`jakarta.validation` annotations + `@Valid` in controllers)
