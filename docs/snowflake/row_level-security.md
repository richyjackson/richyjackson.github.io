---
layout: default
title: Snowflake
---

[Home](./index.md)<br><br>
Row-Level Security (RLS) is a data access control mechanism that ensures individuals can only view data that is applicable to them. 
Snowflake controls RLS via Row Access Policies. These are set at schema level and work against the following:
- SELECT statements
- Rows selected by UPDATE, DELETE and MERGE statements.
Permissions can be granted at role level or they can be granted via a centralised mapping table.
#### Simple row filtering
The most efficient with less cost to mapping tables:
1. Create the Row Access Policy
```SQL
CREATE OR REPLACE ROW ACCESS POLICY region_filter_policy
AS (region STRING)
RETURNS BOOLEAN -> 
  CURRENT_ROLE() IN ('REGION_NORTH', 'REGION_SOUTH') AND
    (
        (region = 'North' AND CURRENT_ROLE() = 'REGION_NORTH') OR
        (region = 'South' AND CURRENT_ROLE() = 'REGION_SOUTH')
    );
```
Here roles of REGION_NORTH and REGION_SOUTH are created. The field “region” is mapped to the role
2. Add the policy to the Role
```SQL
ALTER TABLE CUSTOMERS
ADD ROW ACCESS POLICY region_filter_policy
```
#### Using a mapping table to filter the query result
This can come at additional cost but gives you easier to manage control
1. Create the mapping table
```SQL
CREATE OR REPLACE TABLE USER_REGION_MAPPING (USER_NAME STRING, REGION STRING);
INSERT INTO USER_REGION_MAPPING VALUES ('alice', 'North'), ('bob', 'South');
```
2. Create the Row Access Policy
```SQL
CREATE OR REPLACE ROW ACCESS POLICY region_filter_policy
AS (region STRING)
RETURNS BOOLEAN ->
    EXISTS (
        SELECT 1
        FROM USER_REGION_MAPPING
        WHERE USER_NAME = CURRENT_USER()
          AND REGION = region
    );
```
#### Apply the policy
```SQL
ALTER TABLE CUSTOMERS
ADD ROW ACCESS POLICY region_filter_policy ON (REGION);
```
### Managing Row Access Policies
See the code behind a policy
```SQL
DESCRIBE ROW ACCESS POLICY;
```
See available policies
```SQL
SHOW ROW ACCESS POLICIES;
```
See which tables have policies
```SQL
SELECT *
FROM INFORMATION_SCHEMA.ROW_ACCESS_POLICY_REFERENCES
WHERE POLICY_NAME = 'REGION_FILTER_POLICY';
```
Remove a row access policy from a table
```SQL
ALTER TABLE CUSTOMERS
DROP ROW ACCESS POLICY region_filter_policy;
```
Delete a row access policy
```SQL
DROP ROW ACCESS POLICY region_filter_policy;
```
