```python
CREATE OR REPLACE PROCEDURE TRANSFER_SFTP_TO_TABLE("remote_file_name" VARCHAR, "destination_table" VARCHAR)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('paramiko','snowflake-snowpark-python')
HANDLER = 'main'
EXTERNAL_ACCESS_INTEGRATIONS = (SFTP_<host>_CO_UK_EXT_INT)
SECRETS = ('cred'=SFTP_<host>_CO_UK_CRED)
COMMENT='Transfers data from SFTP to Snowflake'
EXECUTE AS OWNER
AS '

import snowflake.snowpark as snowpark
import _snowflake
import paramiko
import pandas as pd
import csv
import io
from datetime import datetime, timedelta

def main(session: snowpark.Session, remote_file_name, destination_table):
    # SFTP Connection Details
    sftp_host = "sftp.<host>.co.uk"
    sftp_port = 22
    sftp_cred = _snowflake.get_username_password("cred")
    sftp_username = sftp_cred.username
    sftp_password = sftp_cred.password

    remote_file_path = "/<folder>/" + remote_file_name

    action = remote_file_path + '' to '' + destination_table
    
    try:
    
        # Step 1: Connect to SFTP
        
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(sftp_host, port=sftp_port, username=sftp_username, password=sftp_password)

        sftp = ssh.open_sftp()
        with sftp.open(remote_file_path, ''r'') as file:
#            csv_content = file.read().decode(''utf-8'')
            csv_content = file.read().decode(''iso-8859-1'')
        file_stat = sftp.stat(remote_file_path)
            
        sftp.close()
        ssh.close()

        # Step 2: Load CSV into Pandas DataFrame
        
        df = pd.read_csv(io.StringIO(csv_content), delimiter=''|'', dtype=str)

        row_count = str(len(df))

        # Transfer data to a snowflake table

        session.write_pandas(
            df = df,
            table_name = destination_table,
            auto_create_table=True,
            overwrite=True
        )

        # Populate the logging table

        file_modified_time = datetime.fromtimestamp(file_stat.st_mtime)
        file_modified_time = file_modified_time + timedelta(hours=8)
        
        file_size = file_stat.st_size
        
        
        sql = "INSERT INTO LOG_TABLE (ID, ACTION, FILE_ROW_COUNT, FILE_MODIFIED_TIME, FILE_SIZE, STATUS, MESSAGE) VALUES (LOG_ID.NEXTVAL, ''" + action + "'', ''" + row_count + "'', ''" + str(file_modified_time) + "'', ''" + str(file_size) + "'', ''Success'', ''File Transferred'')"

        session.sql(sql).collect()

        return "Success"

    except Exception as e:

        # Catch the error and place in the logging table

        err_msg = f"Error: {str(e)}"

        sql = "INSERT INTO LOG_TABLE (ID, ACTION, STATUS, MESSAGE) VALUES (LOG_ID.NEXTVAL, ''" + action + "'', ''Failed'', ''" + err_msg + "'')"

        session.sql(sql).collect()
        
        return "Fail"

';
```
