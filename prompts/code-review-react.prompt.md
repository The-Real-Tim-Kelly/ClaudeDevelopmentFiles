---
mode: 'agent'
description: 'Run a structured code review on a React / TypeScript file'
---

# Code Review — React

> **Claude Code usage:** Reference with `@prompts/code-review-react.prompt.md` and include the file(s) to review, e.g. `@prompts/code-review-react.prompt.md @src/features/orders/OrderList.tsx`.

Perform a structured code review focused on correctness, architecture compliance, security, and React/TypeScript best practices.

> **Scope:** The checklist below covers the _minimum_ concerns to verify. Do not limit your review to these items — raise any issue you find, regardless of whether it appears in the list.

## Review Checklist

### Architecture & Design

- [ ] **Component size** — Is the component doing too much? Could it be split into smaller, focused components?
- [ ] **Hook extraction** — Is stateful logic inline in a component that should live in a custom hook?
- [ ] **Prop drilling** — Are props passed through 3+ layers? Should context or a state manager be used?
- [ ] **Co-location** — Is state lifted higher than necessary, causing unnecessary re-renders?
- [ ] **Server state vs client state** — Is server-fetched data stored in local state instead of TanStack Query / SWR?

### TypeScript Quality

- [ ] **`any` usage** — Is `any` used where a proper type or `unknown` would be more appropriate?
- [ ] **Props interface** — Are component props fully typed? Are optional props marked with `?`?
- [ ] **Event handler types** — Are event handlers typed with `React.ChangeEvent<HTMLInputElement>` etc., not `any`?
- [ ] **Non-null assertions** — Is `!` used without a comment explaining why it's safe?
- [ ] **`as` casts** — Are type assertions hiding a type mismatch that should be fixed properly?

### React Correctness

- [ ] **`useEffect` dependencies** — Are all variables used inside `useEffect` listed in the dependency array?
- [ ] **`useCallback` / `useMemo` dependencies** — Same check — missing deps cause stale closures?
- [ ] **Key props** — Are list items keyed with a stable, unique ID (not array index)?
- [ ] **Direct state mutation** — Is state being mutated directly instead of via the setter?
- [ ] **Conditional hooks** — Are any hooks called conditionally or inside loops?
- [ ] **Cleanup** — Do `useEffect` calls that set up subscriptions/timers return a cleanup function?

### Data Fetching (TanStack Query)

- [ ] **Query key structure** — Are query keys arrays that include all parameters the query depends on?
- [ ] **Mutation invalidation** — Do mutations invalidate or update the relevant query cache on success?
- [ ] **Loading/error states** — Are `isLoading` and `isError` states handled in the UI?
- [ ] **Stale time** — Is `staleTime` set appropriately to avoid unnecessary background refetches?

### Security

- [ ] **`dangerouslySetInnerHTML`** — Is it used anywhere? Is the HTML source trusted and sanitized?
- [ ] **User input rendered as HTML** — Is any user-supplied string rendered without escaping?
- [ ] **Sensitive data in state** — Are tokens, passwords, or PII stored in component state / localStorage?
- [ ] **External URLs** — Is `href` or `src` constructed from user input without validation?

### Testing (if test file)

- [ ] Are tests using React Testing Library queries (`getByRole`, `getByText`) over `getByTestId`?
- [ ] Is the test asserting on user-visible behavior, not implementation details?
- [ ] Are async interactions awaited with `waitFor` / `findBy` queries?
- [ ] Are edge cases (empty state, error state, loading state) covered?

## Output Format

For each issue found, report:

- **Severity**: Critical / Major / Minor / Suggestion
- **File + Line**: Reference to the specific code
- **Issue**: Clear description of the problem
- **Recommendation**: Concrete fix or improved code snippet

## Code to Review

Include the file(s) to review alongside this prompt:

```
@prompts/code-review-react.prompt.md @src/features/orders/OrderList.tsx
```
