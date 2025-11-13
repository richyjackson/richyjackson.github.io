## Stored Procedures

### RECOMMENDATION_HISTORY_LOAD Procedure

```javascript
CREATE OR REPLACE PROCEDURE DEV_ANCHOR_DB.IRN_ANALYTICS.RECOMMENDATION_HISTORY_LOAD()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
try {
    // Initialize row count and staging count to always be -1
    var startTime = new Date();
    var rowsProcessed = -1;  // Always -1
    var totalRows = -1;      // Always -1

    // Function to log execution status using stored procedure
    function logExecutionStatus(status, message) {
        const logSQL = `CALL DEV_ANCHOR_DB.IRN_STAGING.LOG_PROCEDURE_EXECUTION(
            ''RECOMMENDATION_HISTORY_LOAD'',
            ''RECOMMENDATION_HISTORY'',
            ''${status}'',
            -1,  -- Always log -1 for rowsProcessed
            -1,  -- Always log -1 for totalRows
            ''Recommendation --> Archival'',
            ''${message.replace(/''/g, "''''")}''
        )`;

        snowflake.execute({ sqlText: logSQL });
    }

    // Log start status BEFORE beginning transaction
    logExecutionStatus(''Started'', ''Starting recommendation history load'');

    // Start transaction
    snowflake.execute({ sqlText: ''BEGIN'' });

    // Perform MERGE operation
    const mergeSQL = `
        MERGE INTO DEV_ANCHOR_DB.IRN_ANALYTICS.RECOMMENDATION_HISTORY AS target
        USING (
            SELECT 
                ISIN,
                SEDOL,  -- Fixed missing comma
                NAME,
                FIELD_NAME,
                NOTES_ID,
                COVERING_ANALYST,
                ASSET_CLASS,
                EXTERNAL_RESEARCH_ATTESTATION,
                HAS_ESG_SEC_INCLUDED,
                HAS_BREACH_UNGC_NORMS,
                HAS_MATERIAL_EXPOSURE,
                INCLUDED_IN_ALTERNATIVES,
                DATE_OF_LATEST_NOTE,
                DATE_OF_LATEST_RECOMMENDATION,
                RECOMMENDATION,
                MD5(CONCAT(
                    COALESCE(ISIN, ''''),
                    COALESCE(SEDOL, ''''),
                    COALESCE(NAME, ''''),
                    COALESCE(FIELD_NAME, ''''),
                    COALESCE(NOTES_ID, ''''),
                    COALESCE(COVERING_ANALYST, ''''),
                    COALESCE(ASSET_CLASS, ''''),
                    COALESCE(EXTERNAL_RESEARCH_ATTESTATION, ''''),
                    COALESCE(HAS_BREACH_UNGC_NORMS, ''''),
                    COALESCE(HAS_ESG_SEC_INCLUDED, ''''),
                    COALESCE(HAS_MATERIAL_EXPOSURE, ''''),
                    COALESCE(INCLUDED_IN_ALTERNATIVES, ''''),
                    DATE_OF_LATEST_NOTE,
                    DATE_OF_LATEST_RECOMMENDATION,
                    COALESCE(RECOMMENDATION, '''')
                )) AS HASH_VALUE,
                CURRENT_TIMESTAMP AS VALID_FROM
            FROM DEV_ANCHOR_DB.IRN_ANALYTICS.RECOMMENDATION
        ) AS source
        ON target.HASH_VALUE = source.HASH_VALUE
        WHEN NOT MATCHED THEN INSERT (
            ISIN,
            SEDOL,
            NAME,
            FIELD_NAME,
            NOTES_ID,
            COVERING_ANALYST,
            ASSET_CLASS,
            EXTERNAL_RESEARCH_ATTESTATION,
            HAS_ESG_SEC_INCLUDED,
            HAS_BREACH_UNGC_NORMS,
            HAS_MATERIAL_EXPOSURE,
            INCLUDED_IN_ALTERNATIVES,
            DATE_OF_LATEST_NOTE,
            DATE_OF_LATEST_RECOMMENDATION,
            RECOMMENDATION,
            HASH_VALUE,
            VALID_FROM
        ) VALUES (
            source.ISIN,
            source.SEDOL,
            source.NAME,
            source.FIELD_NAME,
            source.NOTES_ID,
            source.COVERING_ANALYST,
            source.ASSET_CLASS,
            source.EXTERNAL_RESEARCH_ATTESTATION,
            source.HAS_ESG_SEC_INCLUDED,
            source.HAS_BREACH_UNGC_NORMS,
            source.HAS_MATERIAL_EXPOSURE,
            source.INCLUDED_IN_ALTERNATIVES,
            source.DATE_OF_LATEST_NOTE,
            source.DATE_OF_LATEST_RECOMMENDATION,
            source.RECOMMENDATION,
            source.HASH_VALUE,
            source.VALID_FROM
        )`;

    // Execute merge
    snowflake.execute({ sqlText: mergeSQL });

    // Log success and commit
    logExecutionStatus(''Completed'', ''Recommendation history loaded successfully'');
    snowflake.execute({ sqlText: ''COMMIT'' });

    return "Success: Process completed with row_count = -1 and stg_count = -1.";

} catch (err) {
    // Capture and log error details
    var errorMessage = `Error during execution: ${err.message}. Code: ${err.code || ''UNKNOWN''}`;
    
    try {
        // Rollback the transaction in case of error
        snowflake.execute({ sqlText: ''ROLLBACK'' });

        // Log the error - OUTSIDE the transaction
        logExecutionStatus(''Error'', errorMessage);
    } catch (logErr) {
        // If logging fails, try one more time with a simplified error message
        try {
            snowflake.execute({
                sqlText: `CALL DEV_ANCHOR_DB.IRN_STAGING.LOG_PROCEDURE_EXECUTION(
                    ''RECOMMENDATION_HISTORY_LOAD'',
                    ''RECOMMENDATION_HISTORY'',
                    ''Error'',
                    -1,  -- Always log -1 for rowsProcessed
                    -1,  -- Always log -1 for totalRows
                    ''Recommendation --> Archival'',
                    ''Critical error occurred during execution''
                )`
            });
        } catch (finalErr) {
            // If everything fails, return combined error information
            return `Critical failure: Original error: ${err.message}. Logging error: ${logErr.message}`;
        }
    }
    
    return `Failed: ${errorMessage}`;
}
';
```

### AUTHORS_FULL_LOAD Procedure

```javascript
CREATE OR REPLACE PROCEDURE DEV_ANCHOR_DB.IRN_STAGING.AUTHORS_FULL_LOAD()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
try {
    // Step 1: Log "Started" for Internal Stage → Raw
    try {
        let logStartSQL = `CALL IRN_STAGING.LOG_PROCEDURE_EXECUTION(
            ''AUTHORS_FULL_LOAD'', ''AUTHORS'', ''Started'', 
            NULL, NULL, ''Internal Stage → Raw'', ''Process started'' );`;
        snowflake.execute({ sqlText: logStartSQL });
    } catch (err) {
        return "Logging failed: " + err.message;
    }

    // Step 2: Load new data into IRN_RAW.AUTHORS
    try {
        let loadRawDataSQL = `COPY INTO IRN_RAW.AUTHORS FROM (
            SELECT PARSE_JSON($1) AS data, METADATA$FILENAME AS file_name, CURRENT_TIMESTAMP() AS event_time 
            FROM @DEV_ANCHOR_DB.IRN_RAW.FACTSET_API_STG/AUTHOR
        ) FILE_FORMAT = (TYPE = ''JSON'') PATTERN = ''.*.json'';`;
        snowflake.execute({ sqlText: loadRawDataSQL });
    } catch (err) {
        let logErrorSQL = `CALL IRN_STAGING.LOG_PROCEDURE_EXECUTION(
            ''AUTHORS_FULL_LOAD'', ''AUTHORS'', ''Error'', 
            NULL, NULL, ''Internal Stage → Raw'', ''COPY INTO failed: '' || REPLACE(err.message, '''', '''''') || '' '' );`;
        snowflake.execute({ sqlText: logErrorSQL });
        return "Error in COPY INTO: " + err.message;
    }

    // Step 3: Get raw record count
    let newDataCount = 0;
    try {
        let checkNewDataSQL = `SELECT COUNT(*) FROM IRN_RAW.AUTHORS_STREAM WHERE METADATA$ACTION = ''INSERT'';`;
        let result = snowflake.execute({ sqlText: checkNewDataSQL });
        newDataCount = result.next() ? result.getColumnValue(1) : 0;
    } catch (err) {
        return "Error counting new data: " + err.message;
    }

    // Step 4: Log Completion for Internal Stage → Raw
    try {
        let logRawCompleteSQL = `CALL IRN_STAGING.LOG_PROCEDURE_EXECUTION(
            ''AUTHORS_FULL_LOAD'', ''AUTHORS'', ''Completed'', 
            ` + newDataCount + `, NULL, ''Internal Stage → Raw'', 
            ''` + (newDataCount > 0 ? "Data successfully loaded into RAW" : "No new data found in stream") + `'' );`;
        snowflake.execute({ sqlText: logRawCompleteSQL });
    } catch (err) {
        return "Logging completion failed: " + err.message;
    }

    let stagingCount = 0;

    if (newDataCount > 0) {
        // Step 5: Log "Started" for Raw → Staging
        try {
            let logStagingStartSQL = `CALL IRN_STAGING.LOG_PROCEDURE_EXECUTION(
                ''AUTHORS_FULL_LOAD'', ''AUTHORS'', ''Started'', 
                ` + newDataCount + `, NULL, ''Raw → Staging'', ''Moving data to staging'' );`;
            snowflake.execute({ sqlText: logStagingStartSQL });
        } catch (err) {
            return "Logging staging start failed: " + err.message;
        }

        // Step 6: Delete existing records from staging
        try {
            snowflake.execute({ sqlText: `DELETE FROM IRN_STAGING.AUTHORS;` });
        } catch (err) {
            return "Error in DELETE FROM staging: " + err.message;
        }

        // Step 7: Move new data from raw → staging
        try {
            let insertIntoStagingSQL = `INSERT INTO IRN_STAGING.AUTHORS (
                id, first_name, last_name, isactive, update_user
            ) SELECT 
                f.value:id::VARCHAR AS id,
                f.value:firstName::VARCHAR AS first_name,
                f.value:lastName::VARCHAR AS last_name,
                f.value:isActive::BOOLEAN AS isactive,
                ''BATCH_LOAD'' AS update_user
            FROM IRN_RAW.AUTHORS_STREAM AUTHOR, 
            LATERAL FLATTEN(INPUT => AUTHOR.data) f;`;
            snowflake.execute({ sqlText: insertIntoStagingSQL });
        } catch (err) {
            return "Error in INSERT INTO staging: " + err.message;
        }

        // Step 8: Get staging record count
        try {
            let stagingCountResult = snowflake.execute({ sqlText: `SELECT COUNT(*) FROM IRN_STAGING.AUTHORS;` });
            stagingCount = stagingCountResult.next() ? stagingCountResult.getColumnValue(1) : 0;
        } catch (err) {
            return "Error in staging count: " + err.message;
        }

        // Step 9: Log Completion for Raw → Staging
        try {
            let logStagingCompleteSQL = `CALL IRN_STAGING.LOG_PROCEDURE_EXECUTION(
                ''AUTHORS_FULL_LOAD'', ''AUTHORS'', ''Completed'', 
                ` + newDataCount + `, ` + stagingCount + `, ''Raw → Staging'', 
                ''Data successfully moved to staging'' );`;
            snowflake.execute({ sqlText: logStagingCompleteSQL });
        } catch (err) {
            return "Logging staging completion failed: " + err.message;
        }
    }

    return (newDataCount > 0) ? "Data successfully moved to staging." : "No new data found.";
} 
catch (err) {
    return "Unexpected error: " + err.message;
}
';
```
