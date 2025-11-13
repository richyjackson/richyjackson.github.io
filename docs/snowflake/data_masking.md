## Masking

Snowflake supports both column level masking and row level masking

Column level masking rules are created once and can be applied to multiple columns when defining a table

##### Column Level Masking

**Create a general masking policy**

ISIN value has last 4 characters replaced by XXXX

```sql
CREATE OR REPLACE MASKING POLICY MASK_ISIN_ANALYTICS
AS (ISIN VARCHAR) 
RETURNS VARCHAR ->
CASE
    WHEN CURRENT_ROLE() = 'DEV_ANALYST' 
    THEN 'XXXX' || RIGHT(ISIN, 4) -- Mask all except last 4 characters
    ELSE ISIN -- Show full ISIN for other roles
END;
```

**Apply the masking policy a columm in a table**

```sql
ALTER TABLE DEV_ANCHOR_DB.IRN_ANALYTICS.RECOMMENDATION
MODIFY COLUMN ISIN SET MASKING POLICY MASK_ISIN_ANALYTICS;
```

**Apply masking policy to a view**

```sql
create or replace view DEV_POC.WEATHER.STAGING_TBL_MASKING(
	POSTAL_CODE WITH MASKING POLICY DEV_POC.WEATHER.MASK_POSTAL_CODE,
	COUNTRY,
	DATE_VALID_STD,
	MAX_WIND_SPEED_80M_MPS
) as 

    SELECT
    	POSTAL_CODE,
    	COUNTRY,
    	DATE_VALID_STD,
    	MAX_WIND_SPEED_80M_MPS
    FROM
        STAGING_TBL;

-- Add after creation

ALTER VIEW STAGING_TBL_MASKING MODIFY COLUMN POSTAL_CODE SET MASKING POLICY MASK_POSTAL_CODE
```

**Drop a masking policy**

```sql
DROP MASKING POLICY MASK_POSTAL_CODE
```

##### Query Masking Policies

```sql
-- List out the polices and their names

SHOW MASKING POLICIES IN SCHEMA IRN_ANALYTICS;
SHOW MASKING POLICIES IN DEV_ANCHOR_DB.IRN_ANALYTICS;

-- View the code behind the masking policies

SELECT * FROM SNOWFLAKE.ACCOUNT_USEAGE.MASKING_POLICIES

-- See the code behind a policy (can only be called via the name)

DESC MASKING POLICY MASK_ISIN_ANALYTICS
```

##### Row Level Masking

**Create the row level masking policy**

```sql
CREATE OR REPLACE ROW ACCESS POLICY RECENT_DATES 
    AS (var DATE) RETURNS BOOLEAN ->

    CASE
        WHEN 'DEV_ANALYST' = CURRENT_ROLE() AND var > '01-MAR-2025' THEN TRUE
        WHEN 'SYSADMIN' = CURRENT_ROLE() THEN TRUE
        ELSE FALSE -- If you want all other roles to see data by default set to True
    END;
```

**Apply the policy to a table or view**

```sql
CREATE TABLE sales (
  customer   varchar,
  product    varchar,
  spend      decimal(20, 2),
  sale_date  date,
  region     varchar
)
WITH ROW ACCESS POLICY sales_policy ON (region);

-- Add to a View

ALTER VIEW STAGING_TBL_MASKING ADD ROW ACCESS POLICY RECENT_DATES ON (DATE_VALID_STD);
```

**Remove a Row Access Policy**

To remove a policy entirely you must remove all dependancies

```sql
-- Removing the dependancy

ALTER VIEW STAGING_TBL_MASKING DROP ROW ACCESS POLICY RECENT_DATES

-- Removing the POLICY

DROP ROW ACCESS POLICY RECENT_DATES
```

**Tag-Based Dynamic Masking**

```sql
--Sample code for tag based dynamic masking 
CREATE OR REPLACE TAG pii_gender ;
CREATE OR REPLACE TAG pii_name;
CREATE OR REPLACE TAG pii_dob;


--Set tag to column of the table.
ALTER TABLE DEV_DB.RAW.CUSTOMER MODIFY COLUMN SEX SET TAG pii_gender = 'true';
ALTER TABLE DEV_DB.RAW.CUSTOMER MODIFY COLUMN FIRST_NAME SET TAG pii_name = 'true';
ALTER TABLE DEV_DB.RAW.CUSTOMER MODIFY COLUMN LAST_NAME SET TAG pii_name = 'true';
ALTER TABLE DEV_DB.RAW.CUSTOMER MODIFY COLUMN DOB SET TAG pii_dob = 'true';


--Create masking policy
CREATE OR REPLACE MASKING POLICY mask_gender AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('DEV_BUSINESS_ANALYST') THEN '*** MASKED ***' 
    ELSE val
  END;

CREATE OR REPLACE MASKING POLICY mask_name AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('DEV_BUSINESS_ANALYST') THEN '*** MASKED ***' 
    ELSE val
  END;

CREATE OR REPLACE MASKING POLICY mask_dob AS (val DATE) RETURNS DATE ->
  CASE
    WHEN CURRENT_ROLE() IN ('DEV_BUSINESS_ANALYST') THEN TO_DATE('1900-01-01') 
    ELSE val
  END;


-- Assign masking policy to the tag.
ALTER TAG pii_gender SET MASKING POLICY mask_gender;
ALTER TAG pii_name SET MASKING POLICY mask_name;
ALTER TAG pii_dob SET MASKING POLICY mask_dob;
```
