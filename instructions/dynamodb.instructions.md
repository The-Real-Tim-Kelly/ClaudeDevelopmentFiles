# Amazon DynamoDB Instructions

> **Claude Code:** Reference this file with `@instructions/dynamodb.instructions.md` when working on DynamoDB models, repositories, or queries.

## SDK Setup

- Use **`AWSSDK.DynamoDBv2`** NuGet package
- Register as **singleton** in DI:
  ```csharp
  services.AddSingleton<IAmazonDynamoDB, AmazonDynamoDBClient>();
  services.AddSingleton<IDynamoDBContext, DynamoDBContext>();
  ```
- Use **`DynamoDBContext`** for object-mapped operations; use **`IAmazonDynamoDB`** (low-level) only when needing full control over expressions

## Model Attributes

```csharp
[DynamoDBTable("order-table")]          // ← name comes from config, not hardcoded (see below)
public sealed class OrderRecord
{
    [DynamoDBHashKey("PK")]             // Partition key
    public string Pk { get; set; } = default!;

    [DynamoDBRangeKey("SK")]            // Sort key
    public string Sk { get; set; } = default!;

    [DynamoDBProperty("GSI1PK")]
    public string? Gsi1Pk { get; set; }

    [DynamoDBProperty("CustomerId")]
    public string CustomerId { get; set; } = default!;

    [DynamoDBProperty("Total")]
    public decimal Total { get; set; }

    [DynamoDBProperty("CreatedAt")]
    public string CreatedAt { get; set; } = default!; // ISO-8601 string for sortability

    [DynamoDBVersion]
    public int? Version { get; set; }  // Optimistic concurrency
}
```

## Table Name Configuration

Table names **must never be hardcoded**. Load them from configuration:

```csharp
public sealed class DynamoDbOptions
{
    public const string SectionName = "DynamoDb";
    public string OrderTableName { get; init; } = default!;
}

// appsettings.json
{
  "DynamoDb": {
    "OrderTableName": "my-app-orders-dev"
  }
}

// Usage in repository
public sealed class OrderDynamoRepository(
    IDynamoDBContext context,
    IOptions<DynamoDbOptions> opts)
```

## Access Pattern Documentation

**Always add a comment** above each query documenting the access pattern it serves:

```csharp
// Access pattern: Get all orders for a customer, sorted newest first
// GSI: GSI1 — PK = CUSTOMER#{customerId}, SK begins with ORDER#
var query = context.QueryAsync<OrderRecord>(
    $"CUSTOMER#{customerId}",
    QueryOperator.BeginsWith,
    new[] { "ORDER#" },
    new DynamoDBOperationConfig { IndexName = "GSI1" });
```

## Query Rules

- **Never do a full table scan** — always query by PK, SK, or a GSI
- Use `QueryAsync` (returns multiple items) over `LoadAsync` only when fetching by PK returns one item
- Use `BatchGetAsync` for fetching multiple known keys — do not loop `LoadAsync`
- Use `BatchWriteAsync` for bulk writes (max 25 items per batch)
- Paginate large result sets with the `PaginationToken` from `AsyncSearch<T>`

## Write Safety

Use **condition expressions** on writes to prevent race conditions and data loss:

```csharp
// Prevent overwriting an existing item
await context.SaveAsync(record, new DynamoDBOperationConfig
{
    ConditionalExpression = "attribute_not_exists(PK)"
});

// Optimistic concurrency via [DynamoDBVersion] attribute
// DynamoDBContext handles this automatically when the attribute is present
```

## Key Design Patterns

### Single-Table Design (preferred for related access patterns)

```
PK                  SK                  Data
------------------  ------------------  ----
CUSTOMER#<id>       CUSTOMER#<id>       Customer attributes
CUSTOMER#<id>       ORDER#<orderId>     Order summary
ORDER#<orderId>     ORDER#<orderId>     Full order details
ORDER#<orderId>     ITEM#<itemId>       Order line item
```

### Hierarchical SK Patterns

- Use `ENTITY#<id>` key prefixes to namespace items
- Use ISO-8601 date strings in SK for time-based sorting: `ORDER#2026-05-16T10:00:00Z#<orderId>`

## Error Handling

```csharp
try
{
    await context.SaveAsync(record, config, ct);
}
catch (ConditionalCheckFailedException)
{
    // Item already exists or version mismatch
    throw new ConflictException($"Order {record.Pk} already exists or was modified concurrently.");
}
```

## GSI Design Checklist

Before adding a GSI, confirm:
1. Is this access pattern queried frequently enough to justify the cost?
2. Is the GSI partition key highly selective (avoids hot partitions)?
3. Are you projecting only the attributes needed (KEYS_ONLY, INCLUDE, or ALL)?
4. Is the GSI name stored in configuration, not hardcoded?
