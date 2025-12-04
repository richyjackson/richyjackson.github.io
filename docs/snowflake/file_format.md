---
layout: default
title: Snowflake
---

[Home](./index.md)

### File Formats

File for loading data. Such as a CSV file which is pipe delimited.

```sql
create file format CSV_COMMA_LF_HEADER
    type = 'CSV' 
    field_delimiter = ',' 
    record_delimiter = '\n' -- the n represents a Line Feed character
    skip_header = 1 
;
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
FROM '<stage_path>'
FILE_FORMAT = (FORMAT_NAME = 'CSV_PIPE_HEADER')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
```

### Additional settings are:

```sql
error_on_column_count_mismatch -- Can't be used with skip_header
parse_header = TRUE; -- This will try to match column names in the source to the output
strip_outer_array = TRUE -- Used for JSON cleaning up any outer square brackets
```
