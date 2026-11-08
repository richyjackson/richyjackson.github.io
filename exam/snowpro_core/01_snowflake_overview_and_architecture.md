# 1 Snowflake Overview and Architecture

## Table of Contents
- [What is the Snowflake platform](#what-is-the-snowflake-platform)
- [Software as a Service](#software-as-a-service)
- [Snowflake Industry Compliance](#snowflake-industry-compliance)
- [The Snowflake Architecture](#the-snowflake-architecture)
  - [Snowflake Editions](#snowflake-editions)
  - [Snowflakes Three-Tier Architecture](#snowflakes-three-tier-architecture)
- [Tools and Interfaces](#tools-and-interfaces)
- [Data Sharing](#data-sharing)
- [Snowflake Partner Ecosystem](#snowflake-partner-ecosystem)

## What is the Snowflake platform
The three most prominents data architectures are supported:
- **Data Lakehouse** Store all your company data within the platform making it available to data consumers using standard SQL
- **Data Warehouse** Allows you to model your data and process changes in real-time wihtout user intervention
- **Data Mesh** Organisational approach for sharing, accessing and managing analytics data
- Snowflake supports SQL, Java, Scala & Python
- It charges pay as you go in a consumption model
- Due to elastic scalability it can cater for data science workloads
- It provides AI capability through Intelligence and Cortex services
- Snowflakes Native Application Framework allows the build of apps distributed through the Snowflake Marketplace
- **Snowflake Horizon** provides governance and security capabilities
- It includes data lineage and quality monitoring tools
## Software as a Service
Snowflake is a Software as a Service offering:
- It runs completely on cloud infrastructure
- There is no hardware to manage install or configure
- There is no software to download or install
## Snowflake Industry Compliance
- **Health Insurance Portability and Accountability Act (HIPAA)** is certification for safeguarding protected healthcare information (PHI)
- **SOC1, SOC2 Type 2, and PCI DSS** are standards to protect consumer data and credit card information
- **FEDRAMP** Federal Risk and Authorisation Management Program is a US Goverenment program for standardising security assessment, authorisation and continuous monitoring
## The Snowflake Architecture
Snowflake breaks away from traditional architecture constrainted by hardware, networks and storage by providing:
- **Unlimited Storage** allowing the store of structured, semi-structured an unstructured data
- **Elastic Computing** providing multi-cluster compute resources when required
- **Separation** with compute, storage and services being positioned within independant layers
- **Cross-Cloud Freedom** Snowflake runs natively on AWS, Azure and Google Cloud
- **Snowgrid** allows you to replicate data across platforms, enable collaboratiuon without silos, meet compliance standards and reduce vendor lock in
- **Snowflake Horizon** integrates compliance, security, privacy and access controls
- **Snowflake Cortex** brings machine learning and AI applications to your data
### Snowflake Editions
- **Standard** the basic level offering
- **Enterprise** for large scale enterprise clients including data protection and performance features
- **Business Critical** add enhanced security features for organisations with highly sensitive data, failover/rollback and disaster recovery
- **Virtual Private Snowflake (VPS)** offering the highest level of security and is isolated from all other Snowflake accounts

Business Critical and VPS Snowflake editions provide support for Private Connectivity to the Snowflake Service using AWS PrivateLink, Azure Private Link, or Google Cloud Private Service
### Snowflakes Three-Tier Architecture
Snowflake consists of three architectural layers:
- **Cloud Services Layer** which looks after the overall management of the Snowflake account, user authentication, metadata, its storage and infrastructure management. It manages query planning, optimisation and query pruning
- **Query Processing Layer** managing all query execution. Compute is elastic so can scale up and down and is controlled via Virtual Warehouse (CPU & RAM)
- **Database Storage Layer** which manages and organises your data in its optimaised formats. Data is stored in micro-partitions up to 50-500MB based on a clustering key
## Tools and Interfaces
Snowflake has a variety of different interfaces:
- **Classic Web UI** a browser based web interface
- **Snowsight** is the successor to the classic web ui with increased features with the ability to create data visualisations and analyse data
- **Snowpark** allows data  scientists and engineers to interact with your data using Scala, java or Python
- **Workspaces** provides a developer experience for managing code assests with GIT integration
- **Notebooks** built in Jupiter and Anaconda notebooks and allows users to swith between SQL, Python and Markdown
- **Streamlit** an open source python based tool for creating interactive web apps
- **SnowSQL** is Snowflakes command line terminal based client for database operations
- **Snowflake CLI** is an open source command line interface to streamline workflows, provide some automation or portabiloity across platforms
## Data Sharing
- Data can be shared instantly with consumers via **shares** without any data movement. There are two main types of account for sharing:
- **Data Providers** makes data available to other Snowflake accounts
- **Data Consumer** obtains read only data fromm the data provider

The data marketplace allows you to create and host your own data share securely to select members
## Snowflake Partner Ecosystem
Your Snowflake environment can be enhanced by partnering it with other data sources and technologies.
- Examples include data integration, transformation, business intelligence, security and governance, and machine learning
- **Cloud Partners** are those that have developed products that work well with Snowflake via the partner ecosystem
- You can access these technologies via the **Partner Connect Portal**
- Examples include, Alation (data cataloging), Data Robot (AI Cloud Platform)
