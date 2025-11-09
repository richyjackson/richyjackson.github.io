---
layout: default
---

[Link to another page](./index.md)

[Snowflake SQL](wiki/Test)

#### File Formats

File for loading data. Such as a CSV file which is pipe delimited.

```sql
create file format CSV_COMMA_LF_HEADER
    type = 'CSV' 
    field_delimiter = ',' 
    record_delimiter = '\n' -- the n represents a Line Feed character
    skip_header = 1 
;
```
#### Additional settings are:

```sql
error_on_column_count_mismatch -- Can't be used with skip_header
parse_header = TRUE; -- This will try to match column names in the source to the output
strip_outer_array = TRUE -- Used for JSON cleaning up any outer square brackets
```
