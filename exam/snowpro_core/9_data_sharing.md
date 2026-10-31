# 9 Data Sharing

## Table of Contents
- [Secure Data Shares](#secure-data-shares)
- [Data Marketplace and Data Exchange](#data-marketplace-and-data-exchange)
- [Private Data Exchange](#private-data-exchange)
  - [Reader accounts](#reader-accounts)
- [Native Applications](#native-applications)
- [Data Clean Rooms](#data-clean-rooms)

- Data sharing is a metadata only operation and handled by the cloud services layer
- **Data providers** own the data and share with others, they create a share in their Snowflake account and grants the required access to objects they wish to share
- **Data consumers** get read only access to the share and appears like any other database
## Secure Data Shares
- By default you get access to the share SNOWFLAKE_SAMPLE_DATA
## Data Marketplace and Data Exchange
- Gain instant access to external dataset via a catalogue
## Private Data Exchange
- A private data hub for collaboration between specific members
- Data providers and consumers must have a full Snowflake account
### Reader accounts
- A reader account is used to allow a data consumer to access data without a Snowflake account
- The reader would consumer your own credits
- To configure go to Admin > Accounts
## Native Applications
- They are self contained SAAS applications which can be installed within your Snowflake enivornment and are installed via your marketplace
- They avoid issues around transfer of data outside of your environment, security concerns and data silos
## Data Clean Rooms
- Are a protected space for multiple parties (internal & external) to collaborate with your data at the same time
- Only approved analysis can take place without exposing raw data
- Datasets can be compared only where there is a match
