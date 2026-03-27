#### Directory File Exists Test

This works on the OWNER setting. CALLER options available using LIST FILES with simpler syntax.<BR><BR>
**NB: Directory files should be refreshed for this to work correctly**

```SQL
CREATE OR REPLACE PROCEDURE SP_FILE_CONFIG_STAGE_FILE_EXISTS("P_FILE_ID" VARCHAR)
RETURNS VARIANT
LANGUAGE SQL
EXECUTE AS OWNER
AS DECLARE

    STAGE_PATH          VARCHAR;
    FILE_NAME_PATTERN   VARCHAR;
    DIRECTORY_PATH      VARCHAR;
    RELATIVE_PATH       VARCHAR;
    
    STAGE_FILE_EXISTS   INT;
    CONFIG_EXISTS       BOOLEAN;
    ERR_MSG             VARCHAR;

BEGIN

-- Populate the file config parameters

    SELECT  STAGE, FILE_NAME_PATTERN
    INTO    :STAGE_PATH, :FILE_NAME_PATTERN
    FROM    FILE_CONFIG
    WHERE   FILE_ID = :P_FILE_ID;

-- Identify the variables to run the stage DIRECTORY function

    DIRECTORY_PATH      := SPLIT_PART(:STAGE_PATH, '/', 1);
    RELATIVE_PATH       := SUBSTR(:STAGE_PATH,LENGTH(:DIRECTORY_PATH)+2) || :FILE_NAME_PATTERN;
    STAGE_FILE_EXISTS   := (SELECT COUNT(*) FROM DIRECTORY(:DIRECTORY_PATH) WHERE REGEXP_LIKE(RELATIVE_PATH, :RELATIVE_PATH, 'i'));

-- Populate any config issues in the ERR_MSG variable

    IF (STAGE_FILE_EXISTS = 0) THEN

        ERR_MSG := 'Stage File: ' || :STAGE_PATH || :FILE_NAME_PATTERN || ' does not exist';

    END IF;

-- Identify if all tests passed

    CONFIG_EXISTS := (SELECT IFF(:ERR_MSG IS NULL, TRUE, FALSE));        

-- Return the outcome as a boolean value

RETURN 

    OBJECT_CONSTRUCT('CONFIG_EXISTS', :CONFIG_EXISTS, 'ERR_MSG', :ERR_MSG, 'STAGE_FILE', :RELATIVE_PATH);

END;
```
