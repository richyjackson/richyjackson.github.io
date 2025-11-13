

```sql
SELECT $1, $2, $3, $4, $5, $6, $7, $8 FROM '@DEV_DB.SANDBOX.STG_XPLAN/ODS';

TRUNCATE TABLE DEV_DB.SANDBOX.RAW_ODS;

CREATE OR REPLACE TABLE DEV_DB.SANDBOX.RAW_ODS (RAW_DATA VARIANT);

CREATE OR REPLACE FILE FORMAT DEV_DB.SANDBOX.JSON_STRIP_OUTER_ARRAY
    TYPE = 'JSON'
    STRIP_OUTER_ARRAY = TRUE
;

COPY INTO SANDBOX.RAW_ODS
FROM (
    SELECT * FROM '@DEV_DB.SANDBOX.STG_XPLAN/ODS/'
    (FILE_FORMAT => 'DEV_DB.SANDBOX.JSON_STRIP_OUTER_ARRAY')
); 

FROM @DEV_DB.SANDBOX.STG_XPLAN/ODS/
(FILE_FORMAT => 'DEV_DB.SANDBOX.JSON_STRIP_OUTER_ARRAY');

CREATE OR REPLACE VIEW SANDBOX.VW_ODS_FLATTENED AS
    
    SELECT
        RAW_DATA:Sequence::STRING AS SEQUENCE,
        RAW_DATA:Content.Header.Action::STRING AS ACTION,
        RAW_DATA:Content.Header.Correlation_id::STRING AS CORRELATION_ID,
        RAW_DATA:Content.Header.Created_by::STRING AS CREATED_BY,
        RAW_DATA:Content.Header.Source::STRING AS SOURCE,
        RAW_DATA:Content.Header.Subject::STRING AS SUBJECT,
        RAW_DATA:Content.Header.Subject_id::STRING AS SUBJECT_ID,
        RAW_DATA:Content.Header.Timestamp::STRING AS TIMESTAMP,
        b.VALUE:Display::VARCHAR AS DISPLAY, 
        b.VALUE:Field::VARCHAR AS FIELD, 
        b.VALUE:Type::VARCHAR AS TYPE, 
        b.VALUE:Value::VARCHAR AS VALUE,
        b.VALUE::STRING JSON_ARRAY
    FROM
        DEV_DB.SANDBOX.RAW_ODS,
        LATERAL FLATTEN(input => RAW_DATA:Content:Body) b
    WHERE
        RAW_DATA:Content.Header.Action <> 'HEARTBEAT'
    ;

SELECT * FROM SANDBOX.VW_ODS_FLATTENED;

CREATE OR REPLACE VIEW SANDBOX.VW_ODS_PIVOT AS

SELECT
    SEQUENCE::INT AS SEQUENCE,
    ACTION::VARCHAR AS ACTION,
    CORRELATION_ID::VARCHAR AS CORRELATION_ID,
    TIMESTAMP::VARCHAR AS TIMESTAMP,
    SUBJECT_ID::INT AS TASK_ID,
    "'priority'"::VARCHAR AS PRIORITY,
    "'status'"::VARCHAR AS STATUS,
    "'subject'"::VARCHAR AS SUBJECT,
    "'assigner'"::VARCHAR AS ASSIGNER,
    "'assignee'"::VARCHAR AS ASSIGNEE,
    "'subtype'"::VARCHAR AS SUBTYPE,
    "'taskkind'"::VARCHAR AS TASKKIND,
    "'duedate'"::DATE AS DUEDATE,
    "'client'"::INT AS CLIENT,
    "'activateddate'"::DATE AS ACTIVATEDDATE,
    "'completedate'"::DATE AS COMPLETEDATE,
    "'threadid'"::INT AS THREADID,
    "'outcome_text'"::VARCHAR AS OUTCOME_TEXT
FROM (

    SELECT
        SEQUENCE, ACTION, CORRELATION_ID, TIMESTAMP, SUBJECT_ID, FIELD, VALUE
    FROM
        SANDBOX.VW_ODS_FLATTENED)
    PIVOT (
        MAX(VALUE) FOR FIELD IN ('priority', 'status', 'subject', 'assigner', 'assignee', 'subtype', 'taskkind', 'duedate', 'client', 'activateddate', 'completedate', 'threadid', 'outcome_text')
    );

SELECT * FROM SANDBOX.VW_ODS_PIVOT WHERE ACTION = 'INSERT';

SELECT * FROM SANDBOX.VW_ODS_PIVOT WHERE ACTION = 'UPDATE';
```
```JSON
{
  "Content": {
    "Body": [
      {
        "Display": null,
        "Field": "activateddate",
        "Type": "DATE",
        "Value": "2024-12-02"
      },
      {
        "Display": null,
        "Field": "assignee",
        "Type": "INTEGER",
        "Value": 1098918
      },
      {
        "Display": null,
        "Field": "duedate",
        "Type": "DATE",
        "Value": "2024-12-02"
      }
    ],
    "Header": {
      "Action": "UPDATE",
      "Correlation_id": "d6b3ed78-b063-11ef-9ec5-0ab1716739a7",
      "Created_by": 1,
      "Source": "MANUAL",
      "Subject": "task",
      "Subject_id": "4064033",
      "Timestamp": "2024-12-02T04:13:52.222549+00:00"
    }
  },
  "Sequence": 108047678
}



  {
    "Content": {
      "Body": [],
      "Header": {
        "Action": "HEARTBEAT",
        "Correlation_id": "406f5cf6-b06a-11ef-bebd-062f1723e0df",
        "Created_by": 1,
        "Source": "SYSTEM",
        "Subject": null,
        "Subject_id": null,
        "Timestamp": "2024-12-02T04:59:46.583625+00:00"
      }
    },
    "Sequence": 108047777
  }
```
