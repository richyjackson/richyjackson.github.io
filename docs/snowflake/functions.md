## Functions
```sql
CREATE OR REPLACE FUNCTION "CONVERT_DATE_FORMAT"("INPUT_DATE" VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS '

    CONCAT(
        SUBSTR(INPUT_DATE, 7, 4), ''-'', -- Extract the year
        SUBSTR(INPUT_DATE, 4, 2), ''-'', -- Extract the month
        SUBSTR(INPUT_DATE, 1, 2) -- Extract the day
    )
';
```
The JSON library is only supported in Python 3.8
```SQL
CREATE OR REPLACE FUNCTION GET_FILE_COUNT_FOR_DATE("FILE_DATE" VARCHAR)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('requests', 'snowflake-snowpark-python', 'pandas')
HANDLER = 'fird_api_data'
EXTERNAL_ACCESS_INTEGRATIONS = (FIRD_ACCESS_INTEGRATION)
```
When using input variable, they must be declared within the function declaration
```SQL
CREATE OR REPLACE FUNCTION GET_FILE_COUNT_FOR_DATE("FILE_DATE" VARCHAR)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('requests', 'snowflake-snowpark-python', 'pandas')
HANDLER = 'fird_api_data'
EXTERNAL_ACCESS_INTEGRATIONS = (FIRD_ACCESS_INTEGRATION)
AS '

import requests
session = requests.Session()
import snowflake.connector
import pandas as pd
import json

def fird_api_data(FILE_DATE):
```
