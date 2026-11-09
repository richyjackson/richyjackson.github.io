# Restore Database

Source: https://sites.google.com/view/bideveloperwiki/home/restore-database

Restore databases in code

```sql
declare @path varchar(255) = N'E:{bak file location}.bak'
declare @file int = 1

RESTORE DATABASE {
FILE = N'{DB Name}' FROM DISK = @path
WITH FILE = @file,
MOVE N'{DB Name}' TO N'D:{mdf file location}.mdf',
MOVE N'{DB Name}_log' TO N'E:{ldf file location}.ldf',
NOUNLOAD, REPLACE, STATS = 10
```
