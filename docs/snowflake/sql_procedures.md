## Procedures

### 1) Read data from a stage with error handling

```sql
CREATE OR REPLACE PROCEDURE DEV_ANCHOR_DB.IRN_RAW.LOAD_AUTHORS_FROM_STAGE()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS OWNER
AS '
BEGIN
    -- Execute COPY INTO command to load data
    EXECUTE IMMEDIATE ''
        COPY INTO IRN_RAW.AUTHORS
        FROM (
            SELECT
                PARSE_JSON($1) AS data,         
                METADATA$FILENAME AS file_name,
                CURRENT_TIMESTAMP() AS event_time 
            FROM @DEV_ANCHOR_DB.IRN_RAW.FACTSET_API_STG/AUTHOR
        )
        FILE_FORMAT = (TYPE = ''''JSON'''')
        PATTERN = ''''.*.json''''
        ON_ERROR = ''''CONTINUE'''';
    '';
    
    RETURN ''Data successfully loaded into IRN_RAW.AUTHORS'';
    
EXCEPTION 
    WHEN OTHER THEN 
        RETURN ''Error occurred: '' || SQLERRM;
END;
';
```

### 2. Full program flow

```sql
CREATE OR REPLACE PROCEDURE DEV_ANCHOR_DB.IRN_STAGING.IDENTIFIERS_FULL_LOAD_V2()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS '
BEGIN
    -- Step 1: Log "Started" for Internal Stage → Raw
    CALL DEV_ANCHOR_DB.IRN_STAGING.LOG_PROCEDURE_EXECUTION(
        ''IDENTIFIERS_FULL_LOAD_V2'', ''IDENTIFIERS'', ''Started'', 
        NULL, NULL, ''Internal Stage → Raw'', ''Process started''
    );

    -- Step 2: Load new data into IRN_RAW.IDENTIFIERS
    COPY INTO IRN_RAW.IDENTIFIERS 
    FROM (
        SELECT 
            PARSE_JSON($1) AS data, 
            METADATA$FILENAME AS file_name, 
            CURRENT_TIMESTAMP() AS event_time 
        FROM @DEV_ANCHOR_DB.IRN_RAW.FACTSET_API_STG/IDENTIFIERS
    ) 
    FILE_FORMAT = (TYPE = ''JSON'') 
    PATTERN = ''.*.json'';

    -- Step 3: Check if there''s new data and log count
    DECLARE
        new_raw_count INTEGER;
    BEGIN
        SELECT COUNT(*) 
        INTO :new_raw_count 
        FROM IRN_RAW.IDENTIFIERS_STREAM 
        WHERE METADATA$ACTION = ''INSERT'';

        CALL DEV_ANCHOR_DB.IRN_STAGING.LOG_PROCEDURE_EXECUTION(
            ''IDENTIFIERS_FULL_LOAD_V2'', ''IDENTIFIERS'', ''Completed'', 
            :new_raw_count, 
            NULL, ''Internal Stage → Raw'', 
            CASE 
                WHEN :new_raw_count > 0 THEN ''Data successfully loaded into RAW'' 
                ELSE ''No new data found in RAW'' 
            END
        );

        -- Only proceed with staging operations if we have new data
        IF (:new_raw_count > 0) THEN
            -- Step 4: Log "Started" for Raw → Staging
            CALL DEV_ANCHOR_DB.IRN_STAGING.LOG_PROCEDURE_EXECUTION(
                ''IDENTIFIERS_FULL_LOAD_V2'', ''IDENTIFIERS'', ''Started'', 
                NULL, NULL, ''Raw → Staging'', ''Process started''
            );

            -- Step 5: Delete existing staging data ONLY if we have new data
            DELETE FROM IRN_STAGING.IDENTIFIERS;

            -- Step 6: Move new data from raw → staging
            INSERT INTO IRN_STAGING.IDENTIFIERS (
                id, cusip, entity_Id, isin, name, sedol, ticker, update_user
            ) 
            SELECT 
                f.value:query::VARCHAR AS id, 
                f.value:instrumentMetadata.cusip::VARCHAR AS cusip,
                f.value:instrumentMetadata.entityId::VARCHAR AS entity_Id,
                f.value:instrumentMetadata.isin::VARCHAR AS isin,
                f.value:instrumentMetadata.name::VARCHAR AS name,
                f.value:instrumentMetadata.sedol::VARCHAR AS sedol,
                f.value:instrumentMetadata.ticker::VARCHAR AS ticker,
                ''BATCH_LOAD'' AS update_user
            FROM IRN_RAW.IDENTIFIERS_STREAM IDENTIFIER, 
            LATERAL FLATTEN(INPUT => IDENTIFIER.data) f
            WHERE IDENTIFIER.METADATA$ACTION = ''INSERT'';

            -- Step 7: Log Completion for Raw → Staging
            CALL DEV_ANCHOR_DB.IRN_STAGING.LOG_PROCEDURE_EXECUTION(
                ''IDENTIFIERS_FULL_LOAD_V2'', ''IDENTIFIERS'', ''Completed'', 
                :new_raw_count,
                (SELECT COUNT(*) FROM IRN_STAGING.IDENTIFIERS), 
                ''Raw → Staging'', 
                ''Data successfully moved to staging''
            );
        ELSE
            -- Log that we''re skipping staging operations due to no new data
            CALL DEV_ANCHOR_DB.IRN_STAGING.LOG_PROCEDURE_EXECUTION(
                ''IDENTIFIERS_FULL_LOAD_V2'', ''IDENTIFIERS'', ''Completed'', 
                0,
                (SELECT COUNT(*) FROM IRN_STAGING.IDENTIFIERS), 
                ''Raw → Staging'', 
                ''Skipped staging operations - no new data to process''
            );
        END IF;
    END;

    RETURN ''Code Executed Successfully'';
END;
';
```

### Adding Variables

```sql
CREATE OR REPLACE PROCEDURE DEV_ANCHOR_DB.IRN_STAGING.LOG_PROCEDURE_EXECUTION("PROC_NAME" VARCHAR, "TABLE_NAME" VARCHAR, "PROC_ACTION" VARCHAR, "RAW_COUNT" NUMBER(38,0), "STG_COUNT" NUMBER(38,0), "PROCESS_FLOW" VARCHAR, "MESSAGE" VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE 
    ERR_CODE INTEGER;
    ERR_STATE STRING;
    ERR_MSG STRING;
BEGIN
    BEGIN
        -- Try to insert log entry
        IF (PROC_ACTION = ''Started'') THEN
            INSERT INTO IRN_STAGING.PROCESS_LOG (
                SP_NAME, TABLE_NAME, STATUS, RAW_COUNT, STG_COUNT, 
                PROCESS_FLOW, MESSAGE, START_TIME
            ) VALUES (
                :PROC_NAME, :TABLE_NAME, ''Started'', :RAW_COUNT, :STG_COUNT, 
                :PROCESS_FLOW, :MESSAGE, CURRENT_TIMESTAMP()
            );

        ELSEIF (PROC_ACTION = ''Completed'') THEN
            UPDATE IRN_STAGING.PROCESS_LOG
            SET STATUS = ''Completed'',
                RAW_COUNT = :RAW_COUNT,
                STG_COUNT = :STG_COUNT,
                PROCESS_FLOW = :PROCESS_FLOW,
                MESSAGE = :MESSAGE,
                END_TIME = CURRENT_TIMESTAMP()
            WHERE SP_NAME = :PROC_NAME
              AND TABLE_NAME = :TABLE_NAME
              AND STATUS = ''Started''
              AND PROCESS_FLOW = :PROCESS_FLOW
              AND START_TIME = (
                  SELECT MAX(START_TIME) 
                  FROM IRN_STAGING.PROCESS_LOG 
                  WHERE SP_NAME = :PROC_NAME 
                    AND TABLE_NAME = :TABLE_NAME 
                    AND STATUS = ''Started''
                    AND PROCESS_FLOW = :PROCESS_FLOW
              );
        END IF;

        RETURN ''Logged Successfully'';
    EXCEPTION
        WHEN OTHER THEN
            
            
            ERR_MSG := SQLERRM;

            INSERT INTO IRN_STAGING.PROCESS_LOG (
                SP_NAME, TABLE_NAME, STATUS, RAW_COUNT, STG_COUNT, 
                PROCESS_FLOW, MESSAGE, START_TIME
            )
            VALUES (
                ''LOG_PROCEDURE_EXECUTION'', ''PROCESS_LOG'', ''Error'', NULL, NULL, 
                ''Failure'',:ERR_MSG, CURRENT_TIMESTAMP()
            );

        

        RETURN ''Error occurred1: '' || SQLSTATE || '' (Code: '' || SQLCODE || '', Msg: ''|| SQLERRM || '')'';
    END;
END;
';
```

### Use Variables

```sql
CREATE PROCEDURE ADD_XPORT_CONFIG (stage_path STRING, file_format STRING, target_table STRING)

RETURNS STRING
LANGUAGE SQL
AS
$$

    BEGIN

        INSERT INTO DEV_DB.SANDBOX.XPORT_PROCESS_CONFIG (STAGE_PATH, FILE_FORMAT, TARGET_TABLE, ENABLED) VALUES (:stage_path, :file_format, :target_table, 1);

        RETURN 'Added successfully';
        
    END;

$$;
```

```sql
CREATE OR REPLACE PROCEDURE DEV_DB.SANDBOX.PROCESS_XPORT (stage_path STRING, file_format STRING, target_table STRING)

    RETURNS STRING
    LANGUAGE SQL
    AS
    $$
    
        DECLARE
        
            copy_sql STRING;
            truncate_sql STRING;
            
        BEGIN
        
            truncate_sql := 'TRUNCATE TABLE ' || target_table || '';

                EXECUTE IMMEDIATE :truncate_sql;           
            
            copy_sql := '
                             COPY INTO ' || target_table || 
                           ' FROM ' || stage_path ||
                           ' FILE_FORMAT = (FORMAT_NAME = ' || file_format || ')';
        
                EXECUTE IMMEDIATE :copy_sql;
        
            RETURN 'COPY INTO executed successfully for ' || target_table;
            
        END;
    
    $$;
```

```sql
CREATE OR REPLACE PROCEDURE FIRDS.STAGING.C_GET_FILE_COUNT_FOR_DATE("FILE_TYPE" VARCHAR, "FILE_DATE" VARCHAR)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('requests','snowflake-snowpark-python')
HANDLER = 'main'
EXTERNAL_ACCESS_INTEGRATIONS = (FIRD_ACCESS_INTEGRATION)
COMMENT='user-defined procedure'
EXECUTE AS OWNER
AS '

import requests
session = requests.Session()
import json

def main(FILE_TYPE, FILE_DATE):

    var_file_type = FILE_TYPE
    var_file_date = FILE_DATE
    
    baseurl = "https://api.data.fca.org.uk/fca_data_firds_files"

    urlAPI = f"{baseurl}?q=((file_type:{var_file_type})%20AND%20(publication_date:[{var_file_date}%20TO%20{var_file_date}]))&from=0&size=100&pretty=true"
    response = requests.get(urlAPI)
    data = response.json()
        
    file_count = data["hits"][''total'']

    return file_count
    
';
```

### Moving data to a stage via an api call

```sql
CREATE OR REPLACE PROCEDURE load_api_data_custom()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('requests', 'pandas', 'snowflake-snowpark-python')
HANDLER = 'getData'
EXTERNAL_ACCESS_INTEGRATIONS = XXXXX #Replace with actual integration name
EXECUTE AS OWNER
AS
$$
import requests as rq
import pandas as pd

def getData(SESSION):
    apiurl= XXXXXXX  # Replace with your actual API URL and Headers
    header = {'Content-Type': 'application/json',
              'Accept-Encoding': 'deflate'}

    response = rq.get(apiurl, headers=header)
    data = response.json()
    df = pd.DataFrame(data)

    SESSION.write_pandas(df, table_name=<<table_name>>, database=<<db_name>>, schema=<<schema_name>>)

    return "Data loaded successfully"
$$;
```

### SQL Procedures with a Variable

```sql
CREATE OR REPLACE PROCEDURE DEV_DM.CONFIG.BZ_POPULATEDATA_RJ(VAR_TASKID NUMBER(38,0))
RETURNS NUMBER(38,0)
LANGUAGE SQL
EXECUTE AS OWNER
AS 'BEGIN

    ------------Security Data-----------

    INSERT INTO PROCESSRUNAUDITLOG (TASKID, STARTDATETIME, OBJECTNAME, DESCRIPTION, SOURCEROWCOUNT, STATUS)

        SELECT :VAR_TASKID, CURRENT_TIMESTAMP, ''SECURITY'', ''@RAW_INT_STG.Security.csv -> RAW.SECURITY'', a.ROW_COUNT, ''Started''
        FROM (SELECT COUNT(*) -1 ROW_COUNT FROM (SELECT $1 FROM @DEV_DM.RAW.RAW_INT_STG/SECURITY.csv)) a;

    END'
```

### Error Handling

```sql
    BEGIN
        
        INSERT INTO PROCESSRUNAUDITLOG (TASKID, STARTDATETIME, OBJECTNAME, DESCRIPTION, SOURCEROWCOUNT, STATUS)
    
            SELECT :VAR_TASKID, CURRENT_TIMESTAMP, ''PRICES'', ''@RAW_INT_STG.Prices.csv -> RAW.PRICES'', a.ROW_COUNT, ''Started''
           FROM (SELECT COUNT(*) -1 ROW_COUNT FROM (SELECT $1 FROM @DEV_DM.RAW.RAW_INT_STG/PRICES.csv)) a;
            
        TRUNCATE TABLE   DEV_DM.RAW.PRICES;
    
        COPY INTO  DEV_DM.RAW.PRICES     
        FROM ''@DEV_DM.RAW.RAW_INT_STG/PRICES.csv'' 
        file_format = DEV_DM.RAW.PIPE_CSV_FF;
    
        UPDATE DEV_DM.CONFIG.PROCESSRUNAUDITLOG SET ENDDATETIME = CURRENT_TIMESTAMP, TARGETROWCOUNT = a.ROW_COUNT, STATUS = ''Complete''
        FROM (SELECT COUNT(*) ROW_COUNT FROM RAW.PRICES) a
        WHERE ENDDATETIME IS NULL AND OBJECTNAME = ''PRICES'';

        EXCEPTION
            WHEN OTHER THEN
                LET err_msg := ''Failed: Message:'' || SQLERRM || '', State: '' || SQLSTATE || '', Code: '' || SQLCODE;
                UPDATE DEV_DM.CONFIG.PROCESSRUNAUDITLOG SET STATUS = ''Failed'', ERRORDETAILS = err_msg 
                WHERE ENDDATETIME IS NULL AND OBJECTNAME = ''PRICES'';
           
    END;
```

### RESULTSET

```sql
CREATE OR REPLACE PROCEDURE get_data()
RETURNS TABLE (cs_sold_tiem_sk INTEGER)
LANGUAGE SQL
AS
$$
DECLARE
  res resultset default
  (
  SELECT
    cs_sold_time_sk
  FROM
    snowflake_sample_data.tpcds_sf10tcl.catalog_sales
  WHERE cs_bill_cdemo_sk=1388747
  );
BEGIN
  RETURN TABLE(res);
END;
$$
```
