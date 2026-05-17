---
applyTo: '**/*.cs'
---

# Entity Framework Core Instructions

> **Claude Code:** Reference this file with `@instructions/entityframework.instructions.md` when working on DbContext, repositories, or migrations.

## Core Principles

- **All database access goes through repositories** — `DbContext` is never injected into controllers, services, or application layer classes
- **Always use async EF methods** — `ToListAsync`, `FirstOrDefaultAsync`, `SingleOrDefaultAsync`, `SaveChangesAsync`, etc.
- **No lazy loading** — it's disabled globally. Always eager-load with `.Include()` / `.ThenInclude()`
- **No data annotations on domain entities** — use Fluent API via `IEntityTypeConfiguration<T>` exclusively

## DbContext

```csharp
public sealed class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<Customer> Customers => Set<Customer>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);

        // Global query filter for soft deletes
        modelBuilder.Entity<Order>().HasQueryFilter(o => !o.IsDeleted);
    }
}
```

## Entity Configuration (Fluent API)

```csharp
public sealed class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        builder.ToTable("Order", "dbo");
        builder.HasKey(o => o.Id);

        builder.Property(o => o.CustomerEmail)
            .HasMaxLength(256)
            .IsRequired();

        builder.Property(o => o.Total)
            .HasColumnType("decimal(18,2)")
            .IsRequired();

        builder.Property(o => o.CreatedAt)
            .HasDefaultValueSql("SYSUTCDATETIME()")
            .ValueGeneratedOnAdd();

        builder.Property(o => o.UpdatedAt)
            .HasDefaultValueSql("SYSUTCDATETIME()")
            .ValueGeneratedOnAddOrUpdate();

        builder.HasOne(o => o.Customer)
            .WithMany(c => c.Orders)
            .HasForeignKey(o => o.CustomerId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
```

## Soft Delete Pattern

Every entity that participates in soft delete must:

1. Have `bool IsDeleted` property
2. Have a global query filter in `OnModelCreating`: `HasQueryFilter(e => !e.IsDeleted)`
3. The repository's delete method sets `IsDeleted = true` and calls `UpdateAsync`, never calls EF `Remove()`

## Audit Columns

All entities inherit from (or implement) a base:

```csharp
public abstract class AuditableEntity
{
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
```

Override `SaveChangesAsync` in `AppDbContext` to auto-set these:

```csharp
public override async Task<int> SaveChangesAsync(CancellationToken ct = default)
{
    foreach (var entry in ChangeTracker.Entries<AuditableEntity>())
    {
        if (entry.State == EntityState.Added)
            entry.Entity.CreatedAt = entry.Entity.UpdatedAt = DateTime.UtcNow;
        else if (entry.State == EntityState.Modified)
            entry.Entity.UpdatedAt = DateTime.UtcNow;
    }
    return await base.SaveChangesAsync(ct);
}
```

## Repository Pattern

```csharp
// Interface — Domain or Application layer
public interface IOrderRepository
{
    Task<Order?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<IReadOnlyList<Order>> GetByCustomerAsync(Guid customerId, CancellationToken ct = default);
    Task AddAsync(Order order, CancellationToken ct = default);
    Task UpdateAsync(Order order, CancellationToken ct = default);
    Task DeleteAsync(Guid id, CancellationToken ct = default);
}

// Implementation — Infrastructure layer
public sealed class OrderRepository(AppDbContext db) : IOrderRepository
{
    public async Task<Order?> GetByIdAsync(Guid id, CancellationToken ct = default)
        => await db.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == id, ct);

    public async Task AddAsync(Order order, CancellationToken ct = default)
    {
        await db.Orders.AddAsync(order, ct);
        await db.SaveChangesAsync(ct);
    }
}
```

## Querying

- Load only what you need — use `.Select()` projections when the full entity isn't required
- Use `.AsNoTracking()` for read-only queries that don't need change tracking
- Prefer `.AsSplitQuery()` for queries with multiple collection `.Include()`s to avoid cartesian explosions
- Avoid N+1 — always check that `.Include()` is applied before the result is iterated

## Migrations

- Name format: `YYYYMMDD_ShortDescription` (e.g., `20260516_AddOrderStatusIndex`)
- Never edit a migration that has already been applied to any environment
- For breaking schema changes (column rename, type change) use a multi-step migration sequence
- Test every migration against a local SQL Server instance before committing
- Keep seed data in a separate `DataSeeder` class, not embedded in migration files
