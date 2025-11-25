# Snowflake Materialized Views Cheat Sheet

## Key Commands
### Create a Materialized View
```sql
CREATE MATERIALIZED VIEW view_name AS
SELECT column1, column2
FROM base_table
WHERE condition;
```

### Drop a Materialized View
```sql
DROP MATERIALIZED VIEW view_name;
```

### Show Materialized Views
```sql
SHOW MATERIALIZED VIEWS;
```

---

## Limitations
- Cannot include `DISTINCT`, `GROUP BY`, or non-deterministic functions.
- Cannot reference other materialized views.
- Consumes storage and incurs refresh costs.

---

## Best Practices
- Use for **frequently queried, stable data**.
- Avoid on tables with **high update frequency**.
- Monitor **storage and refresh costs**.
- Combine with **clustering keys** for large datasets.

---

## Quick Example
```sql
CREATE MATERIALIZED VIEW sales_mv AS
SELECT region, SUM(amount) AS total_sales
FROM sales
WHERE sale_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY region;
```
