## Streams

Streams capture records of row level data changes for tables and view objects. This is otherwise known as Change Data Capture (CDC)

Metadata is recorded as follows:

- METADATA$ACTION indicates the DML Operation (INSERT, DELETE)
- METADATA$ISUPDATE Updates are represented by a deletion and insertion. In this event the record is set to TRUE
- METADATA$ROW_ID is the immurable ID for the row allowing for tracking of changes to a row over time

If you copy data from your stream to a table, then data is automatically removed from the stream

##### Stream to capture INSERT, UPDATE, DELETE

```sql
CREATE OR REPLACE STREAM <my_stream_name> ON TABLE <my_table_name> APPEND_ONLY = FALSE;
```

##### Stream to capture INSERT Only

Updates which usually show as a deletion followed by an insertion will not be shown

```sql
CREATE OR REPLACE STREAM <my_stream_name> ON TABLE <my_table_name> APPEND_ONLY = TRUE;
```

Streams will become stale if they are not used within the retention period

#### Clearing a Stream

It is not possible to programmatically clear a Stream. It is best to drop and recreate it.
