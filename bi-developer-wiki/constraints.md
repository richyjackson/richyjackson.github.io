# SQL Constraints

Source: https://sites.google.com/view/bideveloperwiki/home/constraints

## CHECK constraint

```sql
ALTER TABLE [dbo].[projects] WITH CHECK ADD CONSTRAINT [ck_project_end_date] CHECK (([project_end_date]>[project_start_date]))
GO
ALTER TABLE [dbo].[projects] CHECK CONSTRAINT [ck_project_end_date]
```
