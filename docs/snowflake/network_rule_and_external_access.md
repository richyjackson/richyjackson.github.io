The SFTP address must be granted permission to interact with Snowflake which is achieved with a network rule:
```sql
create or replace network rule openfird_network_rule
mode = egress
type = host_port
value_list = ('api.data.fca.org.uk','data.fca.org.uk');
```
```sql
create external access integration my_sftp_integration
  allowed network rules = (my_sftp_network_rule)
  enabled = true
```
