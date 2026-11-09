# Temporal Tables

Source: https://sites.google.com/view/bideveloperwiki/home/temporal-tables

## Turn a table into a Temporal Table

```sql
ALTER TABLE [schema].[table_name]
ADD
    sys_start_time DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL DEFAULT GETUTCDATE(),
    sys_end_time DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (sys_start_time, sys_end_time);

ALTER TABLE [schema].[table_name] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [schema].[table_name_history]));
```

## Remove System Versioning

Do this first if wishing to delete the table or if you wish to edit the history

```sql
ALTER TABLE [schema].[table_name] SET (SYSTEM_VERSIONING = OFF);
```
