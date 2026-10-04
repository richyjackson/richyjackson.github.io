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
𝘔𝘌𝘙𝘎𝘌 𝘐𝘕𝘛𝘖 𝘵𝘢𝘳𝘨𝘦𝘵_𝘵𝘢𝘣𝘭𝘦 ...
𝘞𝘏𝘌𝘕 𝘔𝘈𝘛𝘊𝘏𝘌𝘋 𝘛𝘏𝘌𝘕 𝘜𝘗𝘋𝘈𝘛𝘌 𝘈𝘓𝘓 𝘉𝘠 𝘕𝘈𝘔𝘌
𝘞𝘏𝘌𝘕 𝘕𝘖𝘛 𝘔𝘈𝘛𝘊𝘏𝘌𝘋 𝘛𝘏𝘌𝘕 𝘐𝘕𝘚𝘌𝘙𝘛 𝘈𝘓𝘓 𝘉𝘠 𝘕𝘈𝘔𝘌
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
Converts row values into columns
```sql
SELECT * FROM source_table
PIVOT (aggregate_function(column_to_aggregate)
FOR column_to_pivot IN (value1, value2, value3) );

SELECT * FROM monthly_sales
PIVOT (SUM(sales_amount) FOR month IN ('January' AS jan, 'February' AS feb) );
```
#### UNPIVOT
Converts column data into rows
```sql
SELECT *
FROM source_table
UNPIVOT ( value_column FOR name_column IN (col1, col2, col3) )

SELECT *
FROM quarterly_sales
UNPIVOT (sales_amount FOR quarter IN (q1_sales AS 'Q1', q2_sales AS 'Q2') );



```



## Working with Semi-structured Data


## Working with Unstructured Data



## Iceberg Tables


## Key Considerations
