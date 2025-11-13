## SFTP to Snowflake Stage (Unsupported connections)

Procedure available here: https://sfc-gh-dwilczak.github.io/tutorials/snowflake/sftp/

Use SYSADMIN unless specified

### 1. Create a Stage to host the files

```sql
create stage if not exists files directory = ( enable = true );
```

### 2. Create a compute pool to run the Notebook

```sql
create compute pool sftp
    min_nodes = 1
    max_nodes = 1
    instance_family = cpu_x64_xs;
```

### 3. Create a Network Rule to allow connection to your SFTP site and to download Python packages

```sql
create or replace network rule sftp_network_rule
    mode = egress
    type = host_port
    value_list = ('<UPDATE WITH YOUR URL>:22');

-- We'll need this to download the sftp python package.
create or replace network rule pypi_network_rule
    mode = egress
    type = host_port
    value_list = ('pypi.org', 'pypi.python.org', 'pythonhosted.org',  'files.pythonhosted.org');
```

### 4. Create an API integration to allow download of files from your SFTP and to install Python packages

```sql
use role accountadmin;

create or replace external access integration sftp_external_access
    allowed_network_rules = (sftp_network_rule)
    enabled = true;

create or replace external access integration pypi_access_integration
    allowed_network_rules = (pypi_network_rule)
    enabled = true;

grant usage on integration sftp_external_access to role sysadmin;
grant usage on integration pypi_access_integration to role sysadmin;
```

### 5. Create a Notebook using the file or code below run in a container

Make sure to enable external access to your APIs
### Import packages

```python
# Import python packages
import os
import tempfile
import zipfile
import paramiko

from snowflake.snowpark.context import get_active_session
session = get_active_session()
```

### Create the download function

```python
import os
import tempfile
import zipfile
import paramiko
from snowflake.snowpark import Session

def download_and_stage_file_from_sftp(sftp_details, remote_file_path, stage_location, destination="/"):
    """
    Downloads a file from an SFTP server, handles unzipping if necessary, 
    and uploads all contents to a specified location in a Snowflake stage.

    Args:
        sftp_details (dict): SFTP connection details including 'hostname', 'port', 'username', 'password'.
        remote_file_path (str): Path of the file on the SFTP server.
        stage_location (str): The Snowflake stage location where the file(s) will be uploaded.
        destination (str): The location within the stage to upload the file(s). Default is root ('/').
    """
    # Normalize destination to avoid double slashes
    destination = destination.rstrip("/")
    if not destination.startswith("/"):
        destination = f"/{destination}"

    # Temporary file path
    temp_file_path = tempfile.NamedTemporaryFile(delete=False).name

    try:
        # Initialize SFTP connection
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(
            hostname=sftp_details['hostname'],
            port=sftp_details.get('port', 22),
            username=sftp_details['username'],
            password=sftp_details['password']
        )
        sftp = client.open_sftp()

        # Get the original file name
        original_file_name = os.path.basename(remote_file_path)

        # Download the remote file to the temporary file
        temp_file_download_path = os.path.join(tempfile.gettempdir(), original_file_name)
        sftp.get(remote_file_path, temp_file_download_path)
        print(f"Downloaded file from SFTP server saved temporarily as {temp_file_download_path}")

        sftp.close()
        client.close()

        # Check if the file is a ZIP
        if zipfile.is_zipfile(temp_file_download_path):
            with zipfile.ZipFile(temp_file_download_path, "r") as zip_ref:
                with tempfile.TemporaryDirectory() as temp_extract_dir:
                    zip_ref.extractall(temp_extract_dir)
                    print(f"Files extracted to temporary directory {temp_extract_dir}")

                    # Upload all extracted files to the Snowflake stage at the specified destination
                    session = get_active_session()
                    for file_name in os.listdir(temp_extract_dir):
                        file_path = os.path.join(temp_extract_dir, file_name)
                        upload_path = f"@{stage_location}{destination}/{file_name}"
                        session.file.put(f"file://{file_path}", upload_path, auto_compress=False)
                        print(f"Uploaded {file_name} to stage {upload_path}")
        else:
            # If not a ZIP, upload the single file directly
            session = get_active_session()
            upload_path = f"@{stage_location}{destination}"
            session.file.put(f"file://{temp_file_download_path}", upload_path, auto_compress=False)
            print(f"Uploaded file {original_file_name} to stage {upload_path}")

    except Exception as e:
        print(f"Error during SFTP download or file processing: {e}")
    finally:
        # Clean up the temporary file
        if os.path.exists(temp_file_download_path):
            os.remove(temp_file_download_path)
            print(f"Deleted temporary file {temp_file_download_path}")
```

### Download the file

```python
sftp_details = {
    'hostname': '...',
    'port': 22,
    'username': '...',
    'password': '...'
}
# Location of file on SFTP.
remote_file_path = "directory/file.csv"
# Snowflake Stage location (Database.Schema.Stage).
stage_location = "RAW.SFTP.FILES"
# This is where the file will land in the Snowflake stage.
destination = "/"

download_and_stage_file_from_sftp(sftp_details, remote_file_path, stage_location, destination)
```

### Verify the result

```sql
ls @RAW.SFTP.FILES
```
