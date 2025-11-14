### External Tables with Materialized Views - Complete Example

This example demonstrates how to create an external table connected to CSV files in an S3 bucket, with a materialized view on top for improved 

-- Verify files are accessible
LIST @s3_sales_stage;

### Step 1: Create External Table

```sql
-- Sample CSV structure: order_id, customer_id, product, quantity, price, order_date

CREATE OR REPLACE EXTERNAL TABLE sales_external
(
  order_id INT AS (value:c1::INT),
  customer_id INT AS (value:c2::INT),
  product VARCHAR AS (value:c3::VARCHAR),
  quantity INT AS (value:c4::INT),
  price DECIMAL(10,2) AS (value:c5::DECIMAL(10,2)),
  order_date DATE AS (value:c6::DATE)
)
WITH LOCATION = @s3_sales_stage
FILE_FORMAT = csv_format
AUTO_REFRESH = TRUE
REFRESH_ON_CREATE = TRUE;

-- Verify the external table
SELECT * FROM sales_external LIMIT 10;

-- Check metadata
SELECT COUNT(*) FROM sales_external;
```

### Step 2: Create Materialized View

```sql
-- Create materialized view for aggregated daily sales
CREATE OR REPLACE MATERIALIZED VIEW sales_daily_summary AS
SELECT 
  order_date,
  product,
  COUNT(DISTINCT customer_id) AS unique_customers,
  COUNT(*) AS total_orders,
  SUM(quantity) AS total_quantity,
  SUM(quantity * price) AS total_revenue,
  AVG(quantity * price) AS avg_order_value,
  MIN(price) AS min_price,
  MAX(price) AS max_price
FROM sales_external
GROUP BY order_date, product;

-- Query the materialized view (much faster than querying external table)
SELECT * FROM sales_daily_summary
WHERE order_date >= '2024-01-01'
ORDER BY order_date DESC, total_revenue DESC;
```

### Step 3: Refresh and Maintenance

```sql
-- Check when external table was last refreshed
SELECT * FROM TABLE(INFORMATION_SCHEMA.EXTERNAL_TABLE_FILE_REGISTRATION_HISTORY(
  TABLE_NAME => 'SALES_EXTERNAL',
  START_TIME => DATEADD(days, -7, CURRENT_TIMESTAMP())
));

-- Manually refresh external table metadata if needed
ALTER EXTERNAL TABLE sales_external REFRESH;

-- Manually refresh materialized view
ALTER MATERIALIZED VIEW sales_daily_summary REFRESH;

-- Check materialized view refresh history
SELECT * FROM TABLE(INFORMATION_SCHEMA.MATERIALIZED_VIEW_REFRESH_HISTORY(
  VIEW_NAME => 'SALES_DAILY_SUMMARY'
))
ORDER BY REFRESH_START_TIME DESC;
```

### Step 4: Query Examples

```sql
-- Query external table directly (slower, reads from S3)
SELECT 
  customer_id,
  SUM(quantity * price) AS total_spent
FROM sales_external
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- Query materialized view (faster, reads from Snowflake storage)
SELECT 
  product,
  SUM(total_revenue) AS revenue,
  SUM(total_orders) AS orders
FROM sales_daily_summary
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY product
ORDER BY revenue DESC;

-- Join external table with regular table
SELECT 
  c.customer_name,
  e.product,
  SUM(e.quantity * e.price) AS total_spent
FROM sales_external e
INNER JOIN customers c ON e.customer_id = c.customer_id
WHERE e.order_date >= CURRENT_DATE - 30
GROUP BY c.customer_name, e.product
ORDER BY total_spent DESC;
```

### Alternative: Azure Blob Storage Example

```sql
-- For Azure instead of AWS
CREATE OR REPLACE STORAGE INTEGRATION azure_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'AZURE'
  ENABLED = TRUE
  AZURE_TENANT_ID = 'a123b456-c789-d012-e345-f67890123456'
  STORAGE_ALLOWED_LOCATIONS = ('azure://mystorageaccount.blob.core.windows.net/sales-data/');

CREATE OR REPLACE STAGE azure_sales_stage
  URL = 'azure://mystorageaccount.blob.core.windows.net/sales-data/'
  STORAGE_INTEGRATION = azure_integration
  FILE_FORMAT = csv_format;
```

### Alternative: Google Cloud Storage Example

```sql
-- For GCS instead of AWS
CREATE OR REPLACE STORAGE INTEGRATION gcs_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'GCS'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('gcs://my-gcs-bucket/sales-data/');

CREATE OR REPLACE STAGE gcs_sales_stage
  URL = 'gcs://my-gcs-bucket/sales-data/'
  STORAGE_INTEGRATION = gcs_integration
  FILE_FORMAT = csv_format;
```

### Benefits of This Architecture

**External Table Benefits:**

- Query data without loading it into Snowflake
- Automatic metadata refresh with AUTO_REFRESH
- Cost-effective for infrequently accessed data
- Data stays in your cloud storage

**Materialized View Benefits:**

- Pre-computed aggregations for fast queries
- Automatic refresh when base table changes
- Optimized for frequently-run analytical queries
- Stored in Snowflake for better performance

### Best Practices

1. **Partitioning**: Organize external files by date/region for better performance
1. **File Size**: Keep files between 100-250 MB for optimal scanning
1. **Compression**: Use compressed files (gzip) to reduce data transfer costs
1. **Refresh Strategy**: Balance between data freshness and compute costs
1. **Materialized Views**: Create for frequently-accessed aggregations only
1. **Monitoring**: Regularly check refresh history and query performance
