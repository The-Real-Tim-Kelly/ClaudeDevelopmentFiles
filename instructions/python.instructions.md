# Python Coding Instructions

> **Claude Code:** Reference this file with `@instructions/python.instructions.md` when working on Python code.

---

## Language Version & Style

- Target **Python 3.11+**
- Follow **PEP 8** for all formatting
- Use a formatter (**Black** or **Ruff**) and linter (**Ruff**) — do not write code that would fail either
- All public functions, classes, and modules must have **type hints** (PEP 484); use `from __future__ import annotations` for forward references

---

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Modules, packages | `snake_case` | `order_service.py`, `user_repository` |
| Functions, methods, variables | `snake_case` | `get_order_by_id`, `customer_id` |
| Classes | `PascalCase` | `OrderService`, `PaymentProcessor` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| "Private" (internal) identifiers | `_single_underscore` prefix | `_validate_payload` |
| Type variables | `PascalCase` | `T`, `TEntity` |

---

## Type Hints

```python
from __future__ import annotations
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from myapp.domain.models import Order

# Use built-in generics (Python 3.9+) — not typing.List, typing.Dict
def get_orders(customer_id: str) -> list[Order]:
    ...

# Use X | Y union syntax (Python 3.10+) — not Optional[X] or Union[X, Y]
def find_by_id(order_id: str) -> Order | None:
    ...

# Use TypeAlias for complex types
type OrderId = str
```

---

## Classes & Data Models

- Use **`dataclasses`** for simple data carriers:
  ```python
  from dataclasses import dataclass, field

  @dataclass(frozen=True)   # frozen = immutable
  class CreateOrderRequest:
      customer_id: str
      items: list[OrderItemRequest] = field(default_factory=list)
  ```

- Use **Pydantic `BaseModel`** when you need validation, serialization, or JSON schema (API requests/responses):
  ```python
  from pydantic import BaseModel, EmailStr, field_validator

  class CreateCustomerRequest(BaseModel):
      email: EmailStr
      name: str

      @field_validator("name")
      @classmethod
      def name_must_not_be_blank(cls, v: str) -> str:
          if not v.strip():
              raise ValueError("Name must not be blank")
          return v.strip()
  ```

- Use **`enum.Enum`** for fixed value sets:
  ```python
  from enum import Enum

  class OrderStatus(str, Enum):
      PENDING   = "pending"
      SHIPPED   = "shipped"
      DELIVERED = "delivered"
  ```

---

## Async / Await

- Use **`async def`** and **`await`** consistently — never mix sync and async code in the same call path
- Use `asyncio.gather()` for concurrent independent operations — never `await` them sequentially if they're independent
- Use **`anyio`** or **`asyncio`** for async I/O; avoid `gevent` / `eventlet`
- Never call blocking I/O (file reads, `requests`, `time.sleep`) inside an `async` function — use the async equivalents (`aiofiles`, `httpx`, `asyncio.sleep`)

---

## Error Handling

- Define **domain-specific exceptions** inheriting from a base `AppError(Exception)`:
  ```python
  class AppError(Exception): ...
  class NotFoundError(AppError): ...
  class ConflictError(AppError): ...
  ```
- Never use bare `except:` — always catch specific exception types
- Never swallow exceptions silently — at minimum log and re-raise
- Use `logging` (not `print`) for all diagnostic output:
  ```python
  import logging
  logger = logging.getLogger(__name__)
  logger.error("Failed to process order %s", order_id, exc_info=True)
  ```

---

## Imports & Project Structure

- Group imports: stdlib → third-party → local, separated by blank lines
- Never use `from module import *`
- Avoid circular imports — use `TYPE_CHECKING` guard for type-only imports
- Package layout:
  ```
  src/
    myapp/
      domain/        # entities, interfaces, value objects
      application/   # services, use cases
      infrastructure/ # DB, HTTP clients, external services
      api/           # FastAPI routers / Flask blueprints
  tests/
  ```

---

## Dependency Management

- Use **`pyproject.toml`** (PEP 517/518) — not `setup.py`
- Pin direct dependencies with version ranges; pin transitive dependencies in a lockfile (`uv.lock`, `poetry.lock`)
- Use **virtual environments** — never install packages globally in a project context

---

## Testing (pytest)

- Test file: `test_<module>.py` in a mirrored `tests/` directory structure
- Function name: `test_<method>_<scenario>_<expected_result>`
- Use `pytest.fixture` for shared setup; avoid `setUp`/`tearDown` (unittest style)
- Mock with `unittest.mock.AsyncMock` / `MagicMock`, or **`pytest-mock`**'s `mocker` fixture
- Use **`pytest.mark.asyncio`** (via `pytest-asyncio`) for async tests
- Use `pytest.raises` for exception assertions:
  ```python
  with pytest.raises(NotFoundError, match="Order .* not found"):
      await service.get_by_id("nonexistent")
  ```

---

## Security

- Never use `eval()`, `exec()`, or `pickle.loads()` with untrusted data
- Never format user input into SQL strings — use parameterized queries
- Store secrets in environment variables or a secrets manager — never in source files or committed config
- Use `secrets` module for generating tokens / random values — not `random`
