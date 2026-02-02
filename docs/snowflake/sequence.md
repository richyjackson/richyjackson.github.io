## Snowflake Sequences Guide
- Sequences in Snowflake are schema-level objects that generate unique numeric values.
- They provide a reliable way to create auto-incrementing values that are guaranteed to be unique across concurrent sessions.
### Basic Syntax
```sql
CREATE SEQUENCE sequence_name
  START = 1
  INCREMENT = 1;
```
### Full Syntax with All Options
```sql
CREATE OR REPLACE SEQUENCE sequence_name
  START = 1000
  INCREMENT BY = 1
  MINVALUE = 1
  MAXVALUE = 999999999
  CYCLE = FALSE
  COMMENT = 'Description of the sequence';
```
### Parameter Details
|Parameter     |Description                              |
|--------------|-----------------------------------------|
|`START`       |Initial value                            |
|`INCREMENT BY`|Step size (can be negative)              |
|`MINVALUE`    |Minimum value                            |
|`MAXVALUE`    |Maximum value                            |
|`CYCLE`       |Whether to restart after reaching max/min|
|`ORDER`       |Guarantees values are generated in order |
### Descending sequence: ###
```sql
CREATE SEQUENCE countdown_seq
  START WITH = 1000
  INCREMENT BY = -1
  MINVALUE = 1;
```
### Cycling sequence: ###
```sql
CREATE SEQUENCE ticket_number_seq
  START = 1
  INCREMENT = 1
  MAXVALUE = 9999
  CYCLE = TRUE;
```
### Getting the Next Value
```sql
SELECT <sequence_name>.NEXTVAL;

INSERT INTO customers (customer_id, name, email) VALUES (<sequence_name>.NEXTVAL, 'John Doe', 'john@example.com');
```
### Getting Current Value
`CURRVAL` only returns a value after `NEXTVAL` has been called at least once in the current session.
```sql
SELECT <sequence_name>.CURRVAL;
```
### Using with Default Column Values
```sql
CREATE TABLE customers (
  customer_id NUMBER DEFAULT <sequence_name>.NEXTVAL,
  name VARCHAR(100),
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP());
```
### Alternative approach using AUTOINCREMENT
```sql
CREATE TABLE orders (
  order_id NUMBER AUTOINCREMENT START 1000 INCREMENT 1,
  customer_id NUMBER,
  order_date DATE
);
```
### Viewing Sequences
```sql
SHOW SEQUENCES;

SHOW SEQUENCES LIKE 'customer%';

-- Get detailed information
DESC SEQUENCE <sequence_name>;

-- Query from information schema
SELECT * FROM information_schema.sequences WHERE sequence_name = '<sequence_name>';
```
### Altering Sequences
```sql
ALTER SEQUENCE customer_id_seq SET INCREMENT = 5;

ALTER SEQUENCE customer_id_seq SET START WITH = 5000;

ALTER SEQUENCE order_id_seq
  SET INCREMENT = 10
      MAXVALUE = 999999
      CYCLE = FALSE;

ALTER SEQUENCE old_seq_name RENAME TO new_seq_name;
```
### Dropping Sequences
```sql
DROP SEQUENCE IF EXISTS customer_id_seq;

-- Drop with cascade (removes dependencies)
DROP SEQUENCE customer_id_seq CASCADE;
```
### Composite Keys with Sequences

```sql
CREATE SEQUENCE order_item_seq START = 1 INCREMENT = 1;

CREATE TABLE order_items (
  order_id NUMBER,
  item_sequence NUMBER DEFAULT order_item_seq.NEXTVAL,
  product_id NUMBER,
  quantity NUMBER,
  PRIMARY KEY (order_id, item_sequence)
);
```
### Configuring Permission
```sql
GRANT USAGE ON SEQUENCE customer_id_seq TO ROLE analyst_role;

GRANT OWNERSHIP ON SEQUENCE customer_id_seq TO ROLE admin_role;
```
### Snowflake Docs
[Sequences](https://gbr01.safelinks.protection.outlook.com/?url=https%3A%2F%2Fdocs.snowflake.com%2Fen%2Fsql-reference%2Fsql%2Fcreate-sequence&data=05%7C02%7Crichard.jackson%40trinitybridge.com%7C89f257569e4b45e6182508de4135a8e4%7Cda5c8ad4f11b40c497f8ab680d87f144%7C0%7C0%7C639019895891244451%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=97MCMuX5YVT4iRz5MxmZ9phCbIPvsPy9LQ4pOBIPmks%3D&reserved=0)
