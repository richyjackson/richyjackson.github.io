---
layout: default
title: Snowflake
---

[Home](./index.md)
## COPY INTO

Code can be used to the select the stage, the file stored in the stage and the file format to move data to the table required

### NB: => is used in the lower examples, maybe that will fix the issue

```SQL
copy into INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE 
from @util_db.public.aws_s3_bucket
files = ( 'country_code_to_currency_code.csv')
file_format = ( format_name='UTIL_DB.PUBLIC.CSV_COMMA_LF_HEADER' );
```
Here the file name was not specified which would load all files in the stage
```SQL
copy into ags_game_audience.raw.game_logs
from @uni_kishore/kickoff
file_format = (format_name = FF_JSON_LOGS)
```

```SQL
COPY INTO IRN_RAW.AUTHORS FROM (
            SELECT PARSE_JSON($1) AS data, METADATA$FILENAME AS file_name, CURRENT_TIMESTAMP() AS event_time 
            FROM @DEV_ANCHOR_DB.IRN_RAW.FACTSET_API_STG/AUTHOR
        ) FILE_FORMAT = (TYPE = ''JSON'') PATTERN = ''.*.json'';
```

```SQL
-- These code blocks will work

INSERT INTO hierarchy_team (team) SELECT $1 FROM @HIERARCHY/Teams.csv WHERE $1 <> 'team';

SELECT $1, $2
FROM @smoothies.public.my_uploaded_files/fruits.txt
(file_format => smoothies.public.two_headerrow_pct_delim);

-- Row counts
```
SELECT COUNT(*) -1 ROW_COUNT FROM (SELECT $1 FROM @DEV_DM.RAW.RAW_INT_STG/PRICES.csv)

