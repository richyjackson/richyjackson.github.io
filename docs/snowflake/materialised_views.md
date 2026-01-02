# Materialized Views
- Always up to date. Other processes will pause until a refresh occurs
- Use for **frequently queried, stable data**
- Avoid on tables with **high update frequency**
- Combine with **clustering keys** for large datasets
- Cannot include `DISTINCT`, `GROUP BY`, or non-deterministic functions
- Cannot reference other materialized views

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
