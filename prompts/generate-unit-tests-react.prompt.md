---
mode: 'agent'
description: 'Generate Vitest / React Testing Library tests for a React component or hook'
---

# Generate Unit Tests — React

> **Claude Code usage:** Reference with `@prompts/generate-unit-tests-react.prompt.md` and include the file, e.g. `@prompts/generate-unit-tests-react.prompt.md @src/features/orders/OrderList.tsx`.

Generate complete, production-quality Vitest + React Testing Library tests for the target component or custom hook.

> **Scope:** The scenarios listed below are a _minimum baseline_. Add any additional cases you identify as valuable — do not artificially restrict coverage to this list.

## Conventions

| Concern             | Convention                                                                            |
| ------------------- | ------------------------------------------------------------------------------------- |
| Test framework      | Vitest (`describe`, `it`, `expect`)                                                   |
| Component rendering | React Testing Library (`render`, `screen`, `userEvent`)                               |
| Async utilities     | `waitFor`, `findBy*` queries                                                          |
| Mocking             | `vi.mock(...)` for modules; `vi.fn()` for callbacks                                   |
| File location       | Colocated: `<ComponentName>.test.tsx` next to the source file                         |
| Assertions          | RTL + `@testing-library/jest-dom` matchers (`toBeInTheDocument`, `toHaveValue`, etc.) |
| Query priority      | `getByRole` > `getByLabelText` > `getByText` > `getByTestId`                          |

## What to Generate

1. **Render tests** — does the component render its key content in each state?
2. **At minimum**, tests covering:
   - Default / initial render
   - Loading state (skeleton, spinner)
   - Error state (error message displayed)
   - Empty state (empty list, zero results)
   - Happy path user interaction (click, type, submit)
   - Props variation (required vs optional props, edge-case values)
3. **User interaction** using `userEvent` (not `fireEvent`) for realistic event simulation
4. **Async behaviour** — awaited mutations, query refetches, form submissions
5. **Custom hooks** — tested in isolation with `renderHook`

## Component Test Template

```tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { OrderList } from './OrderList';

const mockOrders = [{ id: '1', reference: 'ORD-001', status: 'pending' }];

describe('OrderList', () => {
  it('renders order rows when data is provided', () => {
    render(<OrderList orders={mockOrders} isLoading={false} />);
    expect(screen.getByText('ORD-001')).toBeInTheDocument();
  });

  it('shows loading skeleton while fetching', () => {
    render(<OrderList orders={[]} isLoading={true} />);
    expect(
      screen.getByRole('status', { name: /loading/i }),
    ).toBeInTheDocument();
  });

  it('shows empty state when no orders exist', () => {
    render(<OrderList orders={[]} isLoading={false} />);
    expect(screen.getByText(/no orders/i)).toBeInTheDocument();
  });

  it('calls onCancel with the correct order id when Cancel is clicked', async () => {
    const user = userEvent.setup();
    const onCancel = vi.fn();
    render(
      <OrderList orders={mockOrders} isLoading={false} onCancel={onCancel} />,
    );

    await user.click(screen.getByRole('button', { name: /cancel/i }));

    expect(onCancel).toHaveBeenCalledWith('1');
  });
});
```

## Custom Hook Test Template

```tsx
import { renderHook, act } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { useOrderForm } from './useOrderForm';

describe('useOrderForm', () => {
  it('initialises with an empty form', () => {
    const { result } = renderHook(() => useOrderForm());
    expect(result.current.values.quantity).toBe(0);
  });

  it('updates quantity on change', () => {
    const { result } = renderHook(() => useOrderForm());
    act(() => result.current.setQuantity(5));
    expect(result.current.values.quantity).toBe(5);
  });
});
```

## TanStack Query — Mocking Strategy

```tsx
// Wrap renders with a QueryClient provider using short retry/stale settings for tests
const queryClient = new QueryClient({
  defaultOptions: { queries: { retry: false, staleTime: Infinity } },
});

const wrapper = ({ children }) => (
  <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
);

render(<MyComponent />, { wrapper });
```

## Target Component / Hook

**Fill in before running:**

- **Component / hook:** e.g. `OrderList`, `useOrderForm`
- **Key states to cover:** e.g. loading, empty, error, populated list
- **Interactions to test:** e.g. cancel button, form submit, pagination click
- **File:** include with `@src/features/orders/OrderList.tsx`
