## Stages

Stages are repositories for data files.

They can be held internally within the Snowflake environment or can be held externally in an Amazon S3 bucket, Microsoft Azure or Google Cloud Platform storage.

Data held in external stages can be queried directly without having to move the data into the snowflake environment.

List all items in your stage

```sql
list @product_metadata;

LIST @DEV_DM.RAW.RAW_INT_STG;
```

Return contents of column 1 for an individual file

```sql
select $1
from @product_metadata/product_coordination_suggestions.txt
```

Return all values in column 1 across all files in the stage

```sql
select $1, $2
from @product_metadata
```

Returns files using the file format for easier reading

```sql
select $1
from @uni_kishore/kickoff
(file_format => ff_json_logs)
```

Query metadata for your files

```sql
select * from directory(@sweatsuits);
```
