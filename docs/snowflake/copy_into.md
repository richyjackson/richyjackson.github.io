---
layout: default
title: Snowflake
---

[Home](./index.md)
## COPY INTO
Code can be used to the select the stage, the file stored in the stage and the file format to move data to the table required.<br>
The COPY INTO command will only import a file once, regardless of how many times it is called.
```SQL
COPY INTO <table_name> 
FROM '<@stage_name>'
FILES = ('<filename>.csv')
FILE_FORMAT = (FORMAT_NAME = '<format_name>');
```
#### Load all files in the stage at once
Removing the files parameter imports all
```SQL
COPY INTO <table_name>
FROM '@<my_stage>'
FILE_FORMAT = (FORMAT_NAME = '<format_name>');
```
#### Loading by column header
```sql
CREATE OR REPLACE FILE FORMAT CSV_PIPE_HEADER
            FIELD_DELIMITER = '|'
            FIELD_OPTIONALLY_ENCLOSED_BY = '\"'
            NULL_IF = ('N/A', '')
            ENCODING = 'WINDOWS-1252'
            PARSE_HEADER = TRUE
            ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;

COPY INTO <my_table>
FROM '<@stage_path>'
FILE_FORMAT = (FORMAT_NAME = 'CSV_PIPE_HEADER')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
```
#### Including metadata
```SQL
COPY INTO <table_name>
FROM (
    SELECT PARSE_JSON($1) AS data, METADATA$FILENAME AS file_name, CURRENT_TIMESTAMP() AS event_time 
    FROM '<@stage_path>')
FILE_FORMAT = (TYPE = ''JSON'') PATTERN = ''.*.json'';
```
#### Row counts
Be mindful that multirow fields will report as 1 row per line.
```SQL
SELECT COUNT(*) -1 ROW_COUNT FROM (SELECT $1 FROM <@stage_path>.csv)
```
#### Adding a pattern
When adding a pattern, the file type must still be added.<br>
Pattern matching uses regex formatting: [REGEX Functions](https://docs.snowflake.com/en/sql-reference/functions-regexp)
```SQL
COPY INTO <table_name>
FROM '<@stage>'
PATTERN = '.*<keyword>.*
FILE_FORMAT = (FORMAT_NAME = '<format_name>');

COPY INTO <table_name>
FROM '<@stage>'
PATTERN = '<file_prefix>([A-Za-z0-9])*_[0-9]{14}.csv'
FILE_FORMAT = (FORMAT_NAME = '<format_name>');
```
#### Exporting data to a file
```SQL
COPY INTO '<stage_file_name_and_extention>' 
FROM <table_or_view_name>
FILE_FORMAT = (FORMAT_NAME = '<format_name>' COMPRESSION = NONE)
SINGLE = TRUE
OVERWRITE = TRUE;
```
