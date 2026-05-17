---
mode: 'agent'
description: 'Generate pytest unit tests for a Python class or module'
---

# Generate Unit Tests — Python

> **Claude Code usage:** Reference with `@prompts/generate-unit-tests-python.prompt.md` and include the file, e.g. `@prompts/generate-unit-tests-python.prompt.md @src/services/order_service.py`.

Generate complete, production-quality pytest tests for the target Python class or module.

> **Scope:** The scenarios listed below are a _minimum baseline_. Add any additional cases you identify as valuable — do not artificially restrict coverage to this list.

## Conventions

| Concern         | Convention                                                                  |
| --------------- | --------------------------------------------------------------------------- |
| Test framework  | pytest                                                                      |
| Mocking         | `unittest.mock` (`patch`, `MagicMock`, `AsyncMock`)                         |
| Assertions      | Plain `assert` with descriptive messages; `pytest.raises` for exceptions    |
| File location   | `tests/<mirror of src path>/test_<module_name>.py`                          |
| Function naming | `test_<method>_<scenario>_<expected_result>`                                |
| Async tests     | `@pytest.mark.asyncio` + `pytest-asyncio`                                   |
| Fixtures        | `@pytest.fixture` — scoped to `function` unless shared state is intentional |

## What to Generate

1. **Test module** mirroring the source module's package path
2. **At minimum**, one test per public function/method covering:
   - Happy path (valid input → expected return value / side-effect)
   - `None` / empty / missing inputs
   - Boundary values
   - Every distinct exception path (`pytest.raises`)
   - Async cancellation or timeout behaviour if applicable
3. **Mock patches** at the correct import path (where the name is _used_, not where it is _defined_)
4. **`@pytest.mark.parametrize`** for logic that branches on varying inputs

## Structure Template

```python
import pytest
from unittest.mock import AsyncMock, MagicMock, patch

from myapp.services.order_service import OrderService


@pytest.fixture
def order_repo() -> MagicMock:
    return MagicMock()


@pytest.fixture
def sut(order_repo: MagicMock) -> OrderService:
    return OrderService(order_repo=order_repo)


class TestCreateOrder:
    async def test_valid_request_returns_order_id(
        self, sut: OrderService, order_repo: MagicMock
    ) -> None:
        # Arrange
        order_repo.add = AsyncMock(return_value=None)
        request = CreateOrderRequest(customer_id="c-1", quantity=2)

        # Act
        result = await sut.create_order(request)

        # Assert
        assert result is not None
        order_repo.add.assert_awaited_once()

    async def test_none_request_raises_value_error(self, sut: OrderService) -> None:
        with pytest.raises(ValueError, match="request"):
            await sut.create_order(None)  # type: ignore[arg-type]

    @pytest.mark.parametrize("quantity", [0, -1, -100])
    async def test_invalid_quantity_raises_validation_error(
        self, sut: OrderService, quantity: int
    ) -> None:
        request = CreateOrderRequest(customer_id="c-1", quantity=quantity)
        with pytest.raises(ValidationError):
            await sut.create_order(request)
```

## Async Test Configuration

Add to `pyproject.toml` or `pytest.ini` to enable async tests:

```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"   # auto-detects async test functions without @pytest.mark.asyncio
```

Or mark the whole module explicitly:

```python
pytestmark = pytest.mark.asyncio
```

## Patching Strategy

Always patch at the point of _use_, not the point of _definition_:

```python
# order_service.py imports `send_email` from myapp.email — patch it HERE:
with patch("myapp.services.order_service.send_email") as mock_send:
    ...
```

## Target Class / Module

**Fill in before running:**

- **Class / module:** e.g. `OrderService`
- **Methods to test:** e.g. `create_order`, `cancel_order`
- **Key scenarios / edge cases:** e.g. order not found, duplicate order, payment failure
- **File:** include with `@src/services/order_service.py`
