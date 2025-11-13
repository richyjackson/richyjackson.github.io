---
layout: default
title: Snowflake
---


## Dynamic Tables

- Dynamic tables automatic check for data changes to underlying tables, populating data as required
- They can be a compositon of multiple tables
- They wont work against Shared View Objects as you require permission to the underlying tables
- If the underlying tables is dropped and recreated, the refresh will fail and you will need to recreate the dynamic  tables

```sql
CREATE OR REPLACE DYNAMIC TABLE ANALYSIS_DTBL
    TARGET_LAG = '1 minute'
    REFRESH_MODE = INCREMENTAL
    INITIALIZE = ON_CREATE
    WAREHOUSE = DEV_BI_WH_XS
    AS
    SELECT * FROM STAGING_TBL;
```

##### Refresh Mode

- Incremental Mode - This only makes changes to values which have changed in the underlying data
- Full Refresh - The entire dataset is truncated and replaced

Compute is only used when there has been a change to the underlying tables. Snowflake can identify this without having to query the data
