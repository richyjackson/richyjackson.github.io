## Tasks

NB: Task scheduling requires the EXECUTE TASK permission at account level for the role that owns the task. Despite being able to execute a task manually you must have the additional permission to accept schedules.

##### Grant role permission to execute task

```sql
GRANT EXECUTE TASK ON ACCOUNT TO ROLE <role>;
```

##### Creating a Task

```sql
create or replace task DEV_ANCHOR_DB.IRN_STAGING.IDENTIFIERS_FULL_LOAD_TASK
	warehouse=DEV_BI_WH_XS
	schedule='USING CRON 1 0 * * * UTC'
	as CALL DEV_ANCHOR_DB.IRN_STAGING.IDENTIFIERS_FULL_LOAD_V2();
```

##### Using Cron

Use to schedule tasks periodically

For a list of time zones, see the list of tz database time zones (in Wikipedia).

```
The cron expression consists of the following fields:

# __________ minute (0-59)
# | ________ hour (0-23)
# | | ______ day of month (1-31, or L)
# | | | ____ month (1-12, JAN-DEC)
# | | | | _  day of week (0-6, SUN-SAT, or L)
# | | | | |
# | | | | |
  * * * * *
```

#### Query Tasks

```sql
-- See available tasks

SHOW Tasks

-- See detailed task executions

SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
```

##### Restarting a suspended task

```sql
ALTER TASK ANALYSIS_HISTORY_TBL_IMPORT_TK RESUME;
```
