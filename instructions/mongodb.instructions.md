# MongoDB Coding Instructions

> **Claude Code:** Reference this file with `@instructions/mongodb.instructions.md` when working with MongoDB.

---

## Naming Conventions

- Database names: **`camelCase`** or **`kebab-case`** — `myAppDb` or `my-app-db`
- Collection names: **`camelCase`**, plural noun — `orders`, `customers`, `productVariants`
- Field names: **`camelCase`** — `customerId`, `createdAt`, `isDeleted`
- Index names: descriptive — `orders_customerId_1_createdAt_-1`

---

## Document Design Principles

### Embed vs Reference

**Embed** when:
- The data is accessed together almost all of the time
- The subdocument has no independent lifecycle (it only exists within the parent)
- The array length is bounded and small (< a few hundred items)

**Reference** when:
- The related document is large and not always needed
- The related document has its own lifecycle (queried, updated independently)
- The relationship is many-to-many

```js
// Embed: order items are always read with the order
{
  _id: ObjectId("..."),
  customerId: ObjectId("..."),    // reference to customers collection
  items: [                        // embedded — always accessed with order
    { productId: ObjectId("..."), quantity: 2, unitPrice: 49.99 }
  ],
  total: 99.98,
  status: "pending",
  createdAt: ISODate("2026-05-16T10:00:00Z"),
  updatedAt: ISODate("2026-05-16T10:00:00Z")
}
```

### Required Fields on Every Document

```js
createdAt: ISODate,   // set on insert
updatedAt: ISODate,   // updated on every write
```

Always use **`ISODate` / `Date` BSON type** for timestamps — never store dates as strings.

---

## Schema Validation

Enforce structure with JSON Schema validation at the collection level:

```js
db.createCollection("orders", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["customerId", "items", "status", "total", "createdAt"],
      properties: {
        customerId: { bsonType: "objectId" },
        status:     { enum: ["pending", "shipped", "delivered", "cancelled"] },
        total:      { bsonType: "decimal" },
        items:      { bsonType: "array", minItems: 1 }
      }
    }
  },
  validationAction: "error"   // reject invalid documents
});
```

---

## Indexing — Critical

MongoDB will **table-scan** any query without a supporting index. Always index:
- Fields used in `find()` filter conditions
- Fields used in `sort()`
- High-cardinality fields used in equality lookups

```js
// Compound index — order matters (ESR rule: Equality → Sort → Range)
db.orders.createIndex({ customerId: 1, createdAt: -1 });

// Partial index — only index active (non-deleted) documents
db.orders.createIndex(
  { customerId: 1 },
  { partialFilterExpression: { isDeleted: { $ne: true } } }
);

// Text index for full-text search
db.products.createIndex({ name: "text", description: "text" });
```

Use `explain("executionStats")` to verify a query uses your index:
```js
db.orders.find({ customerId: id }).sort({ createdAt: -1 }).explain("executionStats");
```

---

## Querying

```js
// Always project only the fields you need
db.orders.find(
  { customerId: ObjectId("..."), isDeleted: { $ne: true } },
  { _id: 1, status: 1, total: 1, createdAt: 1 }
).sort({ createdAt: -1 }).limit(20);
```

- **Never** use `find({})` on a large collection without a filter and limit
- Use **`countDocuments(filter)`** — not `count()` (deprecated) and not `find().count()`
- Use `$lookup` sparingly — MongoDB is optimized for embedded documents, not joins

---

## Aggregation Pipeline

Use the aggregation pipeline for complex queries; avoid multiple round-trips:

```js
db.orders.aggregate([
  { $match: { customerId: ObjectId("..."), isDeleted: { $ne: true } } },
  { $sort:  { createdAt: -1 } },
  { $limit: 20 },
  { $project: { status: 1, total: 1, createdAt: 1 } }
]);
```

Stage order matters for performance: `$match` and `$sort` should come first to use indexes before any `$unwind`, `$group`, or `$lookup`.

---

## Writes

### Upsert
```js
db.customers.updateOne(
  { email: "user@example.com" },
  {
    $set:         { name: "Tim Kelly", updatedAt: new Date() },
    $setOnInsert: { createdAt: new Date() }
  },
  { upsert: true }
);
```

### Atomic Updates — Use Update Operators, Not Full Replacement
```js
// Good — atomic field update
db.orders.updateOne(
  { _id: orderId, status: "pending" },   // condition prevents overwriting wrong state
  { $set: { status: "shipped", updatedAt: new Date() } }
);

// Avoid — replaces entire document, loses fields not included
db.orders.replaceOne({ _id: orderId }, updatedDoc);
```

- Use **optimistic concurrency** with a `version` field and a filter on the expected version for critical updates

---

## Transactions

MongoDB supports multi-document ACID transactions (replica set or sharded cluster required):

```js
const session = client.startSession();
try {
  session.startTransaction();
  await orders.insertOne(order, { session });
  await inventory.updateOne({ productId }, { $inc: { stock: -1 } }, { session });
  await session.commitTransaction();
} catch (err) {
  await session.abortTransaction();
  throw err;
} finally {
  session.endSession();
}
```

Use transactions only when you **need** cross-document atomicity — they carry overhead. Prefer embedding or single-document atomic update operators when possible.

---

## Soft Delete

```js
// Mark deleted — never hard delete unless data retention policy requires it
db.orders.updateOne(
  { _id: orderId },
  { $set: { isDeleted: true, deletedAt: new Date(), updatedAt: new Date() } }
);

// Always exclude in queries
db.orders.find({ customerId: id, isDeleted: { $ne: true } });
```

Use a partial index on `isDeleted` to keep non-deleted queries fast.

---

## Connection Management

- Use a **connection pool** (the official driver manages this automatically — do not create a new `MongoClient` per request)
- Register `MongoClient` as a **singleton** in your DI container
- Set `maxPoolSize`, `minPoolSize`, and `serverSelectionTimeoutMS` explicitly — do not rely on defaults in production
- Store connection strings in environment variables or a secrets manager — never in source code

---

## Security

- Connect as a **least-privilege user** — grant only the roles the application needs (`readWrite` on specific DBs)
- Enable authentication (`--auth`) — MongoDB ships with no auth by default
- Never expose the MongoDB port publicly — keep it inside a VPC/private network
- Use TLS for all connections (`tls=true` in the connection string)
- Never log documents or query results that may contain PII
