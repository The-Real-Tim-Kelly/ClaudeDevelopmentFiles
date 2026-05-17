---
applyTo: '**/*.cs'
---

# FluentValidation Instructions

> **Claude Code:** Reference this file with `@instructions/fluentvalidation.instructions.md` when creating or reviewing FluentValidation validators.

---

## Layer Placement

- Validators live in the **Application layer** (`MyApp.Application/Validators/`)
- Validators validate **request/command objects**, not domain entities
- Domain invariants (business rules) belong on the entity itself — FluentValidation is for API input validation

## Naming & Class Structure

- Validator class name: `<RequestType>Validator` — e.g., `CreateOrderRequestValidator`
- Inherit from `AbstractValidator<T>`
- Define all rules in the constructor
- Seal the class — validators are not designed for inheritance

```csharp
public sealed class CreateOrderRequestValidator : AbstractValidator<CreateOrderRequest>
{
    public CreateOrderRequestValidator()
    {
        RuleFor(x => x.CustomerId)
            .NotEmpty()
            .WithMessage("Customer ID is required.");

        RuleFor(x => x.Items)
            .NotEmpty()
            .WithMessage("At least one order item is required.");

        RuleForEach(x => x.Items)
            .SetValidator(new OrderItemRequestValidator());
    }
}
```

## Rule Writing Style

- One `RuleFor` per property — chain multiple conditions on the same property, not multiple `RuleFor` calls for it
- Use `.WithMessage(...)` on every constraint — don't rely on default messages
- Keep messages user-friendly and specific: `"Email must not exceed 256 characters."` not `"Invalid value."`
- Use `.WithName(...)` to override property name in messages when the property name is technical

```csharp
// Good
RuleFor(x => x.Email)
    .NotEmpty().WithMessage("Email is required.")
    .EmailAddress().WithMessage("Email must be a valid email address.")
    .MaximumLength(256).WithMessage("Email must not exceed 256 characters.");

// Avoid — multiple RuleFor for the same property
RuleFor(x => x.Email).NotEmpty();
RuleFor(x => x.Email).EmailAddress();
```

## Conditional Rules

```csharp
// Only validate ShippingAddress if the order is not digital
RuleFor(x => x.ShippingAddress)
    .NotEmpty()
    .When(x => x.OrderType == OrderType.Physical);
```

## Child Object & Collection Validation

```csharp
// Validate a nested object
RuleFor(x => x.Address)
    .SetValidator(new AddressValidator())
    .When(x => x.Address is not null);

// Validate each item in a collection
RuleForEach(x => x.Items)
    .SetValidator(new OrderItemRequestValidator());
```

## Async Validators (Database Uniqueness Checks)

Use async rules only when a database check is required. Keep async validators minimal:

```csharp
public sealed class CreateCustomerRequestValidator : AbstractValidator<CreateCustomerRequest>
{
    public CreateCustomerRequestValidator(ICustomerRepository repo)
    {
        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MustAsync(async (email, ct) =>
                !await repo.ExistsByEmailAsync(email, ct))
            .WithMessage("An account with this email already exists.");
    }
}
```

## Registration

Register validators from the Application assembly in the DI extension method:

```csharp
// In AddApplicationServices() extension
services.AddValidatorsFromAssembly(typeof(ApplicationAssemblyMarker).Assembly);
```

Enable auto-validation in the API layer so validation errors automatically return 400 before the controller action runs:

```csharp
// In AddApiServices() extension
services
    .AddFluentValidationAutoValidation()
    .AddFluentValidationClientsideAdapters(); // only if MVC views are used
```

## Error Response Shape

With `[ApiController]` + FluentValidation auto-validation, failed requests return `ValidationProblemDetails`:

```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "Email": ["Email must be a valid email address."],
    "Items": ["At least one order item is required."]
  }
}
```

## What NOT to Validate Here

- Authorization / ownership checks → controller or service layer
- Business rule violations (e.g., "cannot cancel a shipped order") → domain entity or service, throw a domain exception
- Database integrity (uniqueness is the exception, see async validators above) → let the DB constraint catch it in most cases
