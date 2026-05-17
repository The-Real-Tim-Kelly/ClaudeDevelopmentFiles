---
applyTo: '**/*.tsx,**/*.jsx'
---

# React Coding Instructions

> **Claude Code:** Reference this file with `@instructions/react.instructions.md` when working on React code.

---

## Core Rules

- **Functional components only** — no class components
- **TypeScript always** — no `.jsx` files in a TypeScript project; all components are `.tsx`
- Use **React 18+** features: concurrent rendering, `useTransition`, `Suspense`
- One component per file; filename matches the component name: `OrderCard.tsx`

---

## Naming Conventions

| Element              | Convention               | Example                                |
| -------------------- | ------------------------ | -------------------------------------- |
| Components           | PascalCase               | `OrderCard`, `CustomerDashboard`       |
| Hooks                | `use` prefix + camelCase | `useOrderData`, `useAuth`              |
| Event handlers       | `handle` prefix          | `handleSubmit`, `handleOrderSelect`    |
| Props interfaces     | `<Component>Props`       | `OrderCardProps`                       |
| Files (components)   | PascalCase               | `OrderCard.tsx`                        |
| Files (hooks, utils) | camelCase                | `useOrderData.ts`, `formatCurrency.ts` |

---

## Component Structure

```tsx
// 1. Imports (external → internal → types)
import { useState, useEffect } from 'react';
import { Order } from '@/types/order';
import { formatCurrency } from '@/utils/format';

// 2. Props interface
interface OrderCardProps {
  order: Order;
  onSelect: (id: string) => void;
}

// 3. Component — arrow function, exported as named export
export function OrderCard({ order, onSelect }: OrderCardProps) {
  // 4. Hooks at top
  const [expanded, setExpanded] = useState(false);

  // 5. Derived values / handlers
  const handleClick = () => onSelect(order.id);

  // 6. Render
  return (
    <div onClick={handleClick}>
      <span>{order.status}</span>
      <span>{formatCurrency(order.total)}</span>
    </div>
  );
}
```

- **Named exports over default exports** — they're refactor-safe and easier to grep
- Do not use `React.FC` — just type props directly and return `JSX.Element` or `ReactNode`

---

## Hooks

- **Custom hooks** for any logic that would be shared across components or is longer than ~5 lines
- Name clearly by what they return, not how they work: `useCurrentUser` not `useFetchUser`
- Hooks must follow the rules of hooks: only called at the top level, only called in React functions

```tsx
// Good: logic extracted, reusable, testable
function useOrderById(id: string) {
  const [order, setOrder] = useState<Order | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    orderApi
      .getById(id)
      .then((data) => {
        if (!cancelled) setOrder(data);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    }; // cleanup prevents state update on unmount
  }, [id]);

  return { order, loading };
}
```

---

## State Management

- **Local state (`useState`)** for UI state that doesn't need sharing (open/close, form fields)
- **`useReducer`** when state transitions are complex or multiple sub-values are updated together
- **React Context** for genuinely global state (auth, theme, locale) — not as a performance optimization
- **Server state** (data from APIs): use **TanStack Query** (`useQuery`, `useMutation`) — do not manually manage loading/error/data state for server data
- For complex client state shared across many components: **Zustand** (lightweight) or **Redux Toolkit** (large apps)

---

## Data Fetching

Use **TanStack Query** for all server-state management:

```tsx
const {
  data: orders,
  isLoading,
  error,
} = useQuery({
  queryKey: ['orders', customerId],
  queryFn: () => orderApi.getByCustomer(customerId),
  staleTime: 1000 * 60, // 1 minute
});

const mutation = useMutation({
  mutationFn: (req: CreateOrderRequest) => orderApi.create(req),
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['orders'] }),
});
```

- Never put `fetch` / `axios` calls directly in components — wrap in an API client module
- API clients live in `src/api/<resource>.ts`

---

## TypeScript Discipline

- No `any` — use `unknown` and narrow with type guards, or define the correct type
- No type assertions (`as SomeType`) unless you can prove safety
- Use `interface` for object shapes that can be extended; `type` for unions, intersections, and computed types
- Keep types co-located with what uses them, or in `src/types/` for shared domain types
- Use `satisfies` operator to validate against a type without widening:
  ```ts
  const config = { apiUrl: '/api', timeout: 5000 } satisfies AppConfig;
  ```

---

## Performance

- Wrap expensive computations in `useMemo`; wrap callbacks passed to child components in `useCallback` — but only when there's a measured performance reason, not by default
- Use `React.memo` on pure presentational components that receive stable props
- Use **code splitting** (`React.lazy` + `Suspense`) for route-level and large feature components
- Avoid anonymous object/array literals in JSX props — they create new references on every render

---

## Testing (React Testing Library + Vitest / Jest)

- Test **behavior**, not implementation — query by role, label, and text, not by class or test IDs
- Use `@testing-library/user-event` over `fireEvent` for simulating user interactions
- Name test files `<Component>.test.tsx` alongside the component
- Mock API calls with **MSW (Mock Service Worker)** for integration-level component tests
- Do not test implementation details (internal state, private methods)

```tsx
test('displays order total when order loads', async () => {
  render(<OrderCard order={mockOrder} onSelect={vi.fn()} />);
  expect(await screen.findByText('$120.00')).toBeInTheDocument();
});
```

---

## Security

- Never `dangerouslySetInnerHTML` with user-provided content — XSS risk
- Sanitize any HTML from external sources with **DOMPurify** before rendering
- Never store tokens or sensitive data in `localStorage` — use `httpOnly` cookies
- Validate all user inputs before sending to the API
