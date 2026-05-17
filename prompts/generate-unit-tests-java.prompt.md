---
mode: 'agent'
description: 'Generate JUnit 5 unit tests for a Java / Spring Boot class'
---

# Generate Unit Tests — Java

> **Claude Code usage:** Reference with `@prompts/generate-unit-tests-java.prompt.md` and include the class file, e.g. `@prompts/generate-unit-tests-java.prompt.md @src/main/java/com/example/service/OrderService.java`.

Generate a complete, production-quality JUnit 5 test class for the target Java class.

> **Scope:** The scenarios listed below are a _minimum baseline_. Add any additional cases you identify as valuable — do not artificially restrict coverage to this list.

## Conventions

| Concern          | Convention                                                                       |
| ---------------- | -------------------------------------------------------------------------------- |
| Test framework   | JUnit 5 (`@Test`, `@ParameterizedTest`)                                          |
| Mocking          | Mockito (`@ExtendWith(MockitoExtension.class)`, `@Mock`, `@InjectMocks`)         |
| Assertions       | AssertJ (`assertThat(...).isEqualTo(...)`, `assertThatThrownBy(...)`)            |
| File location    | `src/test/java/<same package as SUT>/<ClassName>Test.java`                       |
| Method naming    | `methodName_scenario_expectedResult` or `should_expectedBehavior_when_condition` |
| SUT construction | `@InjectMocks` or manual constructor — never mock the SUT itself                 |

## What to Generate

1. **Test class** annotated with `@ExtendWith(MockitoExtension.class)`
2. **At minimum**, one test per public method covering:
   - Happy path (valid input → expected output / side-effect)
   - Null / empty / missing inputs
   - Boundary values
   - Every distinct exception path
3. **Mock verification** (`verify(mock).method(...)`) where a dependency call is required
4. **`@ParameterizedTest`** with `@ValueSource` / `@CsvSource` / `@MethodSource` for logic that branches on varying inputs

## Structure Template

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;

    @Mock
    private PaymentGateway paymentGateway;

    @InjectMocks
    private OrderService sut;

    @Test
    void createOrder_validRequest_returnsOrderId() {
        // Arrange
        var request = new CreateOrderRequest(/* ... */);
        var savedOrder = new Order(UUID.randomUUID(), request.customerId());
        when(orderRepository.save(any(Order.class))).thenReturn(savedOrder);

        // Act
        var result = sut.createOrder(request);

        // Assert
        assertThat(result).isNotNull();
        assertThat(result).isEqualTo(savedOrder.getId());
        verify(orderRepository).save(any(Order.class));
    }

    @Test
    void createOrder_nullRequest_throwsIllegalArgumentException() {
        assertThatThrownBy(() -> sut.createOrder(null))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("request");
    }

    @ParameterizedTest
    @ValueSource(ints = {0, -1, -100})
    void createOrder_invalidQuantity_throwsValidationException(int quantity) {
        var request = new CreateOrderRequest(/* customerId */, quantity);
        assertThatThrownBy(() -> sut.createOrder(request))
            .isInstanceOf(ValidationException.class);
    }
}
```

## Spring Slice Tests

Use slice tests instead of full `@SpringBootTest` wherever possible:

```java
// Controller layer only
@WebMvcTest(OrderController.class)

// JPA layer only — uses an in-memory database
@DataJpaTest

// Full context — use sparingly, only for true integration tests
@SpringBootTest
```

## Target Class

**Fill in before running:**

- **Class:** e.g. `OrderService`
- **Methods to test:** e.g. `createOrder`, `cancelOrder`
- **Key scenarios / edge cases:** e.g. order not found, duplicate order ID, payment gateway failure
- **File:** include with `@src/main/java/com/example/service/OrderService.java`
