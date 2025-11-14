
```sql
CREATE OR REPLACE PROCEDURE "USER_HISTORY_IMPORT"()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS '

DECLARE ERR_MSG STRING;

BEGIN

-- Identify and mark records which have changed

    UPDATE USER_HISTORY AS target
    SET
        STG_ENDDATE = CURRENT_DATE,
        STG_CURRENT = 0
    FROM
        DEV_XPLAN.RAW.XPORT_USER_GROUPS AS source
    WHERE
        COALESCE(target.USERID, '''') = COALESCE(source."USERID", '''') AND
    	(
        	COALESCE(target.FORENAME, '''') != COALESCE(source."Forename", '''') OR
        	COALESCE(target.SURNAME, '''') != COALESCE(source."Surname", '''') OR
        	COALESCE(target.CREATEDDATE, ''1900-01-01'') != COALESCE(source."CreatedDate", ''1900-01-01'')
        ) AND
      target.STG_ENDDATE IS NULL;

-- Add records to history where they are new or modified

    INSERT INTO USER_HISTORY (
    
      STG_STARTDATE,
      STG_ENDDATE,
      STG_CURRENT,
    	FORENAME,
    	SURNAME,
      CREATEDDATE,
    	USERID,
        
    )
    
    SELECT
      CURRENT_DATE,
      NULL,
      1,
    	"Forename",
    	"Surname",
    	"CreatedDate",
    	"UserId"
    FROM
        USER AS source
        LEFT JOIN USER_HISTORY AS target ON
            COALESCE(target.ENTITYID, 0) = COALESCE(source."EntityId", 0) AND 
            COALESCE(target.GROUPENTITYID, 0) = COALESCE(source."GroupEntityId", 0) AND STG_ENDDATE IS NULL
    WHERE
        (target.USERID IS NULL AND target.USERID IS NULL) OR
        (
        	COALESCE(target.FORENAME, '''') != COALESCE(source."Forename", '''') OR
        	COALESCE(target.SURNAME, '''') != COALESCE(source."Surname", '''') OR
        	COALESCE(target.CREATEDDATE, ''1900-01-01'') != COALESCE(source."CreatedDate", ''1900-01-01'')
        );

END
';
```
