
## See also this article: https://medium.com/snowflake/unleashing-the-power-of-snowflake-with-external-network-access-024fd3cbf5a7

CREATE OR REPLACE PROCEDURE DEV_XPLAN.RAW.TRANSFER_SFTP_TO_STAGE()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('paramiko','snowflake-snowpark-python')
HANDLER = 'test_sftp'
EXTERNAL_ACCESS_INTEGRATIONS = (SFTP_IRESS_CO_UK_EXT_INT)
SECRETS = ('cred'=SFTP_IRESS_CO_UK_CRED)
EXECUTE AS OWNER
AS '
import _snowflake
import paramiko
import os 
import tempfile
import snowflake.snowpark as snowpark

def test_sftp(session: snowpark.Session):
    sftp_host = "sftp.iress.co.uk"
    sftp_port = 22
    sftp_cred = _snowflake.get_username_password("cred")
    sftp_username = sftp_cred.username
    sftp_password = sftp_cred.password

    try:
        # Initialize SSH Client
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        # Connect to SFTP Server
        ssh.connect(sftp_host, port=sftp_port, username=sftp_username, password=sftp_password)
        
        # Open SFTP session
        sftp = ssh.open_sftp()

        remote_file_path = "/XPORTS/UserGroups.csv"
        
        # Check if file exists
        try:
            sftp.stat(remote_file_path)
        except FileNotFoundError:
            return "File does not exist"

        # Get the file

        #stage_name = "@XPORT"
        #local_file_path = "/tmp/UserGroups.csv"
        temp_file_path = tempfile.NamedTemporaryFile(delete=False).name
        
        stagepath = "DEV_XPLAN.RAW.XPORT"
        local_file_path = "/"
        local_file_path = local_file_path.rstrip("/")
        if not local_file_path.startswith("/"):
            local_file_path = f"/{local_file_path}"

        original_file_name = os.path.basename(remote_file_path)
        temp_file_download_path = os.path.join(tempfile.gettempdir(),original_file_name)
        
        sftp.get(remote_file_path,temp_file_download_path)
        #with tempfile.TemporaryDirectory() as temp_extract_dir:
        #    for file_name in os.listdir(temp_extract_dir):
        #        file_path = os.path.join(temp_extract_dir, file_name)
        #        upload_path = f"@{stage_location}{localfile_file_path}/{file_name}"
        #        file.put(f"file://{file_path})",upload_path, auto_compressoin)
        upload_path = f"@{stagepath}{local_file_path}"
        session.file.put(f"file://{temp_file_download_path}",upload_path, auto_compress=False, overwrite=True )
        
        #sftp.get(remote_file_path, local_file_path @stage_name)

        # Close connections
        sftp.close()
        ssh.close()
        
        return "File Copied!"
    
    except Exception as e:
        return f"SFTP connection failed: {e}"
';