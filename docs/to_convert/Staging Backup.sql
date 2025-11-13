CREATE OR REPLACE PROCEDURE DEV_DB.SANDBOX.ADD_XPORT_CONFIG("STAGE_PATH" VARCHAR(100), "FILE_FORMAT" VARCHAR(100), "TARGET_TABLE" VARCHAR(100))
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS '

    BEGIN

        INSERT INTO DEV_DB.SANDBOX.XPORT_PROCESS_CONFIG (STAGE_PATH, FILE_FORMAT, TARGET_TABLE, ENABLED) VALUES (:stage_path, :file_format, :target_table, 1);

        RETURN ''Added successfully'';
        
    END;

';

CREATE OR REPLACE PROCEDURE DEV_DB.SANDBOX.PROCESS_ALL_XPORTS()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS ' DECLARE

    cur CURSOR FOR
    
        SELECT STAGE_PATH, FILE_FORMAT, TARGET_TABLE FROM SANDBOX.XPORT_PROCESS_CONFIG WHERE ENABLED = 1;

    V_STAGE_PATH VARCHAR;
    V_FILE_FORMAT VARCHAR;
    V_TARGET_TABLE VARCHAR;
    V_SQL VARCHAR;
    
BEGIN

    FOR record IN cur DO
    
        V_STAGE_PATH := record.STAGE_PATH;
        V_FILE_FORMAT := record.FILE_FORMAT;
        V_TARGET_TABLE := record.TARGET_TABLE;
        V_SQL := ''CALL SANDBOX.PROCESS_XPORT('''''' || V_STAGE_PATH || '''''', '''''' || V_FILE_FORMAT || '''''', '''''' || V_TARGET_TABLE || '''''');'';

        -- Call the procedure with extracted parameters

        BEGIN

            EXECUTE IMMEDIATE :V_SQL;

        END;
        
    END FOR;

    RETURN ''All Xport processed completed successfully''; END; ';

    CREATE OR REPLACE PROCEDURE DEV_DB.SANDBOX.PROCESS_XPORT("STAGE_PATH" VARCHAR, "FILE_FORMAT" VARCHAR, "TARGET_TABLE" VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
COMMENT='Processess a single Xport moving the csv file from the stage to the correponding Xport table'
EXECUTE AS OWNER
AS '

    DECLARE

        comment STRING;
        truncate_target_table STRING;
        add_logging_entry STRING;
        transfer_data STRING;
        mark_log_as_success STRING;
        error_message STRING;
        mark_log_as_failed STRING;
            
    BEGIN

        comment := '''''''';

        add_logging_entry := ''

            INSERT INTO XPORT_LOG (STARTDATETIME, OBJECTNAME, DESCRIPTION, SOURCEROWCOUNT, STATUS)
            
            SELECT
                CURRENT_TIMESTAMP,
                '' || comment || target_table || comment || '', 
                '' || comment || stage_path || '' ==> '' || target_table || comment || '', 
                ROW_COUNT, '' 
                || comment || ''Started'' || comment || ''
            FROM (SELECT COUNT(*) ROW_COUNT FROM '' || comment || stage_path || comment || '') a'' ;

            EXECUTE IMMEDIATE :add_logging_entry;

        truncate_target_table := ''TRUNCATE TABLE '' || target_table ;

            EXECUTE IMMEDIATE :truncate_target_table;           

        transfer_data := ''
        
            COPY INTO '' || target_table || 
            '' FROM '' || stage_path ||
            '' FILE_FORMAT = (FORMAT_NAME = '' || file_format || '')'';

            EXECUTE IMMEDIATE :transfer_data;

        mark_log_as_success := ''
            
            UPDATE XPORT_LOG SET STATUS = '' || comment || ''Success'' || comment || '', ENDDATETIME = CURRENT_TIMESTAMP, TARGETROWCOUNT = ROW_COUNT
            FROM (SELECT COUNT(*) ROW_COUNT FROM '' || target_table || '') a
            WHERE ENDDATETIME IS NULL AND DESCRIPTION = '' || comment || stage_path || '' ==> '' || target_table || comment;

            EXECUTE IMMEDIATE :mark_log_as_success;

    RETURN ''COPY INTO executed successfully for '' || target_table;

    EXCEPTION
        WHEN OTHER THEN
        
        error_message := ''Failed: Message:'' || SQLERRM || '', State: '' || SQLSTATE || '', Code: '' || SQLCODE;

        mark_log_as_failed := ''
            
            UPDATE XPORT_LOG SET STATUS = '' || comment || ''Failed'' || comment || '', ERRORDETAILS = ''|| comment || error_message || comment || '';
            WHERE ENDDATETIME IS NULL AND DESCRIPTION = '' || comment || stage_path || '' ==> '' || target_table || comment;

            EXECUTE IMMEDIATE :mark_log_as_failed;
            
    END;

';