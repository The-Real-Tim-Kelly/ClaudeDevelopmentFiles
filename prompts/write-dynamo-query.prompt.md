# Write DynamoDB Query

> **Claude Code usage:** Copy this prompt into your Claude Code session (or reference with `@prompts/write-dynamo-query.prompt.md`), then fill in the **Query Details** section at the bottom.

Generate a correct, production-safe DynamoDB query using the project's AWS SDK conventions.

## What to Generate

1. **Query method** on the appropriate repository class
   - Typed to return the correct model class (decorated with `[DynamoDBTable]`)
   - Always includes a comment above the method stating the access pattern it serves
   - Uses `DynamoDBContext.QueryAsync<T>()` (preferred) or low-level `IAmazonDynamoDB.QueryAsync()` for projection/filter expressions
   - Handles pagination via `AsyncSearch<T>.GetRemainingAsync()` or manual pagination with `PaginationToken`

2. **GSI name** sourced from `IOptions<DynamoDbOptions>` — never hardcoded

3. **Error handling** for `ConditionalCheckFailedException` and `ProvisionedThroughputExceededException`

## Query Type Guide

| Scenario | Method |
|---|---|
| Get one item by PK + SK | `context.LoadAsync<T>(pk, sk, ct)` |
| Get all items for a PK | `context.QueryAsync<T>(pk, config)` |
| Get items by PK where SK begins with prefix | `QueryAsync` + `QueryOperator.BeginsWith` |
| Get items by GSI | `QueryAsync` + `DynamoDBOperationConfig { IndexName = "..." }` |
| Get multiple known keys | `context.CreateBatchGet<T>()` then `ExecuteBatchGetAsync` |
| Write multiple items | `context.CreateBatchWrite<T>()` then `ExecuteBatchWriteAsync` |

## Key Design Reminders

- **Never use ScanAsync in production** — if you think you need a scan, you need a new GSI
- PK values follow `ENTITY#<id>` prefix convention
- Sort keys follow `ENTITY#<id>` or `ENTITY#<ISO8601-date>#<id>` for time-ordered queries
- All date values stored as ISO-8601 strings (`yyyy-MM-ddTHH:mm:ssZ`) in SK for lexicographic sorting

## Example Output Shape

```csharp
// Access pattern: Get all orders for a customer placed after a given date, newest first
// GSI: CustomerOrdersIndex — PK = CUSTOMER#<id>, SK begins with ORDER#<date>
public async Task<IReadOnlyList<OrderRecord>> GetOrdersByCustomerAsync(
    Guid customerId,
    DateTime after,
    CancellationToken ct = default)
{
    var search = _context.QueryAsync<OrderRecord>(
        $"CUSTOMER#{customerId}",
        QueryOperator.BeginsWith,
        new[] { $"ORDER#{after:yyyy-MM-dd}" },
        new DynamoDBOperationConfig
        {
            IndexName = _opts.Value.CustomerOrdersIndexName,
            BackwardQuery = true  // newest first
        });

    return await search.GetRemainingAsync(ct);
}
```

## Query Details

**Fill in before running** — describe the access pattern in plain language, for example:

- Entity: `OrderRecord`
- Access pattern: Get all orders for a given customer placed after a specific date, sorted newest first
- GSI: `CustomerOrdersIndex` (PK = `CUSTOMER#<id>`, SK begins with `ORDER#<date>`)
- Expected result: collection of `OrderRecord`

> Replace this section with your query details, then send the full prompt to Claude Code.
