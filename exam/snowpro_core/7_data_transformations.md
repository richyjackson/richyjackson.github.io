# 7 Data Transformations
## Working with Relational Data
### User Defined Functions (UDFs)
- UDFs calculate and return a value or set of values
- Supported in Java, Python, JavaScript and SQL
- **Scalar functions** return one output row per input row
- **Table functions** return zero, one or many rows
- Java & Python UDFs support source files containing the code for the UDFs
- It is not pushing to share Java UDFs

### Stored Procedures
- Used to encapsulate business logic or a set of processes, supporting multi-statement code
- They include error handling and branching & looping (not supported in SQL)
- Can be coded in Java, JavaScript, Python, Scala, Snowflake Scripting (for SQL)
- Java, Python & Scala are supported in Snowpark

### MERGE operator
- Provides INSERTS and UPDATES by comparison to source
- Useful for Change Data Capture in conjunction with Streams and Tasks

```sql
MERGE INTO customer_dim AS target
USING customer_updates AS source
  ON target.customer_id = source.customer_id
WHEN MATCHED THEN UPDATE SET
  customer_name = source.customer_name,
  email = source.email,
  last_updated = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN
  INSERT (customer_id, customer_name, email, created_date)
  VALUES (source.customer_id, source.customer_name, source.email, CURRENT_TIMESTAMP());
```
Using ``MATCH ALL BY NAME`` removes need to declare each column
```sql
MERGE INTO target_table ...
WHEN MATCHED THEN UPDATE ALL BY NAME
WHEN NOT MATCHED THEN INSERT ALL BY NAME
```
Delete statements are also supported
```sql
WHEN MATCHED AND source.status = 'DELETED' THEN DELETE
WHEN MATCHED AND source.status = 'UPDATED' THEN UPDATE SET ...
```
### Window Functions
- They perform calculations across sets of rows returning a result against a single row
- They are efficient, however when using partitioning, if these match the clustering they perform better
- They can provide:
  - **Ranking** finding the top N records in each category
  - **Running totals** calculating cumulative sums or averages
  - **Comparing values** looking at previous or next row values
  - **Analytical calculations** computing percentiles, moving averages, or growth rates


#### ROW_NUMBER()
Provides a unique sequential number
```sql
SELECT
  customer_id, order_date, order_amount,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as order_sequence
FROM orders;
```
#### RANK()
Assigns ranks to rows and leaves GAPS where there are TIES
```sql
SELECT
  product_name, sales_amount,
  RANK() OVER (ORDER BY sales_amount DESC) as sales_rank
FROM product_sales;
```
#### DENSE_RANK()
Assigns ranks to rows and leaves NO GAPS where there are TIES
```sql
SELECT
  product_name, sales_amount,
  DENSE_RANK() OVER (ORDER BY sales_amount DESC) as sales_rank
FROM product_sales;
```
#### LAG() and LEAD()
Looks at values before or after the current row
```sql
SELECT
  order_date, sales_amount,
  LAG(sales_amount) OVER (ORDER BY order_date) as previous_day_sales,
  LEAD(sales_amount) OVER (ORDER BY order_date) as next_day_sales,
  sales_amount - LAG(sales_amount) OVER (ORDER BY order_date) as day_over_day_change
FROM daily_sales
ORDER BY order_date;
```
#### FIRST_VALUE() and LAST_VALUE()
Access the first or last value in the window
```sql
SELECT
  customer_id, order_date, order_amount,
  FIRST_VALUE(order_amount) OVER ( PARTITION BY customer_id ORDER BY order_date ) as first_order_amount,
  order_amount - FIRST_VALUE(order_amount) OVER ( PARTITION BY customer_id ORDER BY order_date) as amount_vs_first_order
FROM orders; Aggregate window
```
#### Running totals
```sql
SELECT
  order_date, daily_sales,
  SUM(daily_sales) OVER (ORDER BY order_date) as running_total
FROM daily_sales
ORDER BY order_date;
```
#### Moving averages
```sql
SELECT
  order_date, daily_sales,
  AVG(daily_sales) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as seven_day_moving_average
FROM daily_sales
ORDER BY order_date;
```
### PIVOT and UNPIVOT
#### PIVOT
- Converts row values into columns
- It makes data taller
```sql
SELECT * FROM source_table
PIVOT (aggregate_function(column_to_aggregate)
FOR column_to_pivot IN (value1, value2, value3) );

SELECT * FROM monthly_sales
PIVOT (SUM(sales_amount) FOR month IN ('January' AS jan, 'February' AS feb) );
```
#### UNPIVOT
- Converts column data into rows
- It makes data taller
- Rows with NULL values are excluded, use case statements to preserve these
- Dynamic SQL is needed if you do not know the column headers
```sql
SELECT *
FROM source_table
UNPIVOT ( value_column FOR name_column IN (col1, col2, col3) )

SELECT *
FROM quarterly_sales
UNPIVOT (sales_amount FOR quarter IN (q1_sales AS 'Q1', q2_sales AS 'Q2'));
```
### Common Table Expressions
- For breaking down comple queries and reusing code
- Work with hierarchical data nad use recursive queries
- CTEs only exist for the duration of the query and are evaluated each time they are referenced
- A tempoarary table may be better if a CTE needs to be referenced multiple times
```sql
WITH cte_name AS (
  SELECT columns FROM table WHERE conditions
)

SELECT * FROM cte_name;
```
### Recursive CTEs
- Use for hierarchical data such as organisation structures
- Use `RECURSIVE` keyword
```sql
WITH RECURSIVE employee_hierarchy AS (

-- Anchor: top-level employees

  SELECT employee_id, manager_id, 1 as level
  FROM employees
  WHERE manager_id IS NUL

UNION ALL

-- Recursive: employees reporting to previous level

  SELECT e.employee_id, e.manager_id, eh.level + 1
  FROM employees e
  INNER JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id

)

SELECT * FROM employee_hierarchy;
```
### Estimating Functions
**Cardinality estimation** - HyperLogLog, an algorithm to estimate the number of distinct values in a dataset<p>
**Similarity Estimation** - MinHash, for estimating the similarity of datsets without using set operations<p>
**Percentage Estimation** -t-Digest algorithm, a space and time-efficient way of estimating approximate percentile values in datasets<p>
**Table Sampling** - To return a random subset of rows from a dataset
```sql
select * from testtable sample (10 rows); -- For a fixed number
select * from testtable sample (10); - For a percentage return
```
### Try Functions
- For loading and unloading data where values dont match the expected type
- Where the expected type is not received, NULL is provided
- They have minimal performance overhead
- `TRY_CAST, TRY_TO_NUMBER, TRY_TO_DATE, TRY_TO_TIMESTAMP, TRY_TO_DECIMAL`
## Working with Semi-structured Data
- Snowflake allows you to store semi-structured data in a relational table formal using the data type of `VARIANT`
- JSON, AVRO, Parquet, ORC, or XML can be added directly without having to specify the format
- The maximum length of a variant column is 128 MB
- Snowflake also supports object and arrays with this data type
```sql
create table variant_test (col1 variant);
insert into variant_test select ['London', 'Sydney' ];
select col1[1] from variant_test;
```
#### JSONPath expressioons
- You can access nested elements using colon or bracket notation
```sql
-- Sample JSON in a VARIANT column

SELECT raw_data FROM customer_events;
-- {'customer_id': 123, 'address': {'city': 'London', 'country': 'UK'}}

-- Accessing nested values with colon notation

SELECT
    raw_data:customer_id as customer_id,
    raw_data:address:city as city,
    raw_data:address:country as country
FROM customer_events;

-- Using bracket notation

SELECT raw_data['customer_id'] FROM customer_events;

-- Use the double colon to cast to a specific data type
SELECT
  raw_data:customer_id::INTEGER as customer_id,
  raw_data:order_date::DATE as order_date,
  raw_data:total_amount::DECIMAL(10,2) as total_amount
FROM orders_json;
```
- **PARSE_JSON** - converts a string to a JSON variant
```sql
SELECT PARSE_JSON({"name":"John", "age":30}')
```
- **TO_JSON** - Converts a variant to a JSON string
```sql
SELECT TO_JSON(raw_data) as json_string FROM customer_data
```
- **OBJECT_CONSTRUCT** - Converts relation data to a JSON object
```sql
SELECT OBJECT_CONSTRUCT( 'customer_id', customer_id, 'name', customer_name, 'city', city ) as customer_json
FROM customers;
```
- **GET** - To extract a value from a JSON string `SELECT GET(raw_data, 'customer_id') FROM events;`
- **GET_PATH** - To extract data from a nested path `SELECT GET_PATH(raw_data, 'address.city') FROM events;`
- **FLATTEN** - Converts semi-structured data into relational data. The `LATERAL` keyword allows you to reference the outer query
```sql
-- Source data with array

SELECT raw_data FROM orders;

-- {'order_id': 123, 'items': [{'product': 'A', 'qty': 2}, {'product': 'B', 'qty': 1}]}
-- Flatten the items array

SELECT
  raw_data:order_id::INTEGER as order_id,
  f.value:product::STRING as product,
  f.value:qty::INTEGER as quantity
FROM orders,
  LATERAL FLATTEN(input => raw_data:items) f;
```
## Working with Unstructured Data
- Unstructured data is stored in stages
- A directory table catalogs a list of stages files
```sql
ALTER STAGE my_stage_name SET DIRECTORY = (ENABLE = TRUE);

-- To force a refresh:

ALTER STAGE my_stage_name

-- To query:

SELECT * FROM DIRECTORY(@my_stage);
```
## Iceberg Tables
- Iceberg tables are an open table format designed for large analytic datasets and data lakes
- Data can be queries in your own cloud storage (eg. S3, Azure Blob, GCS) using the Iceberg format without copying data into Snowflake
- It is used to share data across platform
- Avoids vendor lock in - Choose Iceberg tables when interoperability with other engines is
- **Snowflake-Managed Iceberg Tables** - Are where Snowflake manages both the data and the metadata
```sql
CREATE ICEBERG TABLE products
  (product_id INTEGER, product_name STRING, category STRING, price DECIMAL(10,2))
  CATALOG = 'SNOWFLAKE'
  EXTERNAL_VOLUME = 'my_external_volume'
  BASE_LOCATION = 'products/';
```
- **Externally Managed Iceberg Tables** - Are where data and the metadata are managed outside Snowflake (reads data doesnt control)
```sql
CREATE ICEBERG TABLE external_sales
  CATALOG = 'GLUE' -- or 'POLARIS', etc.
  EXTERNAL_VOLUME = 'my_external_volume'
  METADATA_FILE_PATH = 's3://mybucket/sales/metadata/v1.metadata.json';
``
