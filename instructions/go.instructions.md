# Go Coding Instructions

> **Claude Code:** Reference this file with `@instructions/go.instructions.md` when working on Go code.

---

## Language Version & Tooling

- Target **Go 1.22+**
- Run `gofmt` / `goimports` on all code — formatting is non-negotiable
- Use `go vet` and **`golangci-lint`** for static analysis
- Manage dependencies with `go mod` — keep `go.sum` committed

---

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Exported (public) | PascalCase | `OrderService`, `GetByID` |
| Unexported (package-private) | camelCase | `orderRepo`, `validatePayload` |
| Interfaces | Noun or `-er` suffix | `Repository`, `OrderReader` |
| Acronyms | All-caps if exported | `userID`, `parseURL`, `HTTPClient` |
| Package names | Short, lowercase, no underscores | `order`, `customerrepo` |
| Test files | `<file>_test.go`, same package | `order_service_test.go` |

---

## Error Handling

- **Errors are values** — always check and handle them; never `_` an error from a function that can fail
- Wrap errors with context using `fmt.Errorf("getting order %s: %w", id, err)` (use `%w` for unwrapping)
- Define **sentinel errors** with `errors.New` for known failure modes:
  ```go
  var ErrNotFound = errors.New("not found")
  var ErrConflict = errors.New("conflict")
  ```
- Check with `errors.Is` / `errors.As` — never string-match error messages
- **Panic only for unrecoverable programmer errors** (nil pointer in init, impossible state) — not for normal control flow

---

## Interfaces

- Define interfaces **at the point of use** (consumer side), not where the type is defined
- Keep interfaces small — prefer composing small interfaces over large ones:
  ```go
  type OrderReader interface {
      GetByID(ctx context.Context, id string) (*Order, error)
  }

  type OrderWriter interface {
      Save(ctx context.Context, order *Order) error
      Delete(ctx context.Context, id string) error
  }

  type OrderRepository interface {
      OrderReader
      OrderWriter
  }
  ```
- Never return a concrete struct from a constructor when an interface is what callers need

---

## Context

- **Always accept `context.Context` as the first parameter** on functions that do I/O, call external services, or can be cancelled
- Never store a `Context` in a struct — pass it through the call chain
- Use `context.WithTimeout` / `context.WithDeadline` for operations with time limits
- Propagate cancellation: if the caller cancels, all downstream I/O should stop

```go
func (r *orderRepository) GetByID(ctx context.Context, id string) (*Order, error) {
    row := r.db.QueryRowContext(ctx, "SELECT ... FROM orders WHERE id = $1", id)
    ...
}
```

---

## Structs & Constructors

```go
// Use a constructor function for non-trivial structs
type OrderService struct {
    repo   OrderRepository
    logger *slog.Logger
}

func NewOrderService(repo OrderRepository, logger *slog.Logger) *OrderService {
    if repo == nil {
        panic("repo is required")
    }
    return &OrderService{repo: repo, logger: logger}
}
```

- Unexported fields with exported constructor — hide implementation details
- Use **`slog`** (Go 1.21+) for structured logging — not `fmt.Println`, not `log.Printf`

---

## Goroutines & Concurrency

- Never start a goroutine without a clear **ownership and lifecycle** plan — know what stops it and when
- Use `sync.WaitGroup` to wait for a group of goroutines to finish
- Prefer **channels** for communication; prefer **mutexes** for protecting shared state
- Use `errgroup.Group` (from `golang.org/x/sync/errgroup`) for concurrent tasks where you need to collect errors
- Always pair a goroutine that writes to a channel with a `close(ch)` when done

---

## Project Structure

```
cmd/
  myapp/
    main.go          # entry point — wire dependencies, start server
internal/
  domain/            # entities, repository interfaces, domain errors
  application/       # services, use cases
  infrastructure/    # DB implementations, HTTP clients, AWS SDKs
  api/               # HTTP handlers, middleware, routing
pkg/                 # shared libraries safe for external use (optional)
```

- Use `internal/` to prevent external packages from importing your implementation details
- `main.go` is a wiring file only — no business logic

---

## Testing

- Use the standard `testing` package + **`testify`** (`assert`, `require`, `mock`)
- Test function name: `Test<Function>_<Scenario>` — e.g., `TestGetByID_NotFound`
- Use **table-driven tests** for multiple cases:
  ```go
  tests := []struct {
      name    string
      input   string
      want    *Order
      wantErr error
  }{
      {"found", "abc", &Order{ID: "abc"}, nil},
      {"not found", "xyz", nil, ErrNotFound},
  }
  for _, tt := range tests {
      t.Run(tt.name, func(t *testing.T) {
          got, err := svc.GetByID(ctx, tt.input)
          require.ErrorIs(t, err, tt.wantErr)
          assert.Equal(t, tt.want, got)
      })
  }
  ```
- Use **`httptest`** for HTTP handler tests — no need for a running server

---

## Security

- Never interpolate user input into SQL strings — use `$1` / `?` placeholders with `database/sql`
- Use `crypto/rand` for all random/token generation — never `math/rand`
- Store secrets in environment variables or a secrets manager — not in source or committed config files
