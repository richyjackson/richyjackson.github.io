# Snowflake AI & ML

## Table of Contents
- [Key Principles](#key-principles)
- [Snowflake AI & ML Tools and Services](#snowflake-ai--ml-tools-and-services)
- [Snowpark for Machine Learning](#snowpark-for-machine-learning)
- [Model Deployment and Management](#model-deployment-and-management)
- [Use Cases and Examples](#use-cases-and-examples)

## Key Principles
**Complete Data Security** - All models operate within Snowflakes security and governance framework unnless you choose otherwise
**Strict Data Privacy** - There is clear seperation between your data and model activities, models made available to external customers do not expose data
**Familiar Access Management** - AI features follow the same RBAC principles
## Snowflake AI & ML Tools and Services
- Data does not need to be moved to AI models any more
- **CoCo** is an LLM assistant using natural language to help with tasks
- **Document AI** extracts structured data from various document formats
- **Cortex Services** is a suite of products that use LLMs to help you work efficiently with unstructured data such as images and text at scale and your data
- **Cortext AI SQL** integrates industry LLMs (eg. OpenAI, Athropic) queries to provide unstructured analytics on text
- **Cortex Fine-Tuning** creates custommised adaptors for pre-trained models
- **Cortex Search** provides low latency, high quality fuzzy search capabilities for unstructured data
- **Cortex Analyst** allows you to ask natural language questions over your structured data
## Snowpark for Machine Learning
- Allows data scientists to work with machine learning in Python, Java or Scala
- It integrates seamlessly with ML frameworks such as scikit-learn, XGBoost and Pandas
- UDFs encapsulate your ML logic
## Model Deployment and Management
- Models are stored within Snowflake as database objects using the same access control measures
- You can choose between batch inference or real-time predictions
- Monitoring capabilitiues allow you to track prediction accuracy, model drift and performance metrics
- There is a complete audit trail of model useage
## Use Cases and Examples
- **Customer Analytics & Personalisation** retail companies using ortex AI SQL to analyise customer reviews and feedback or creating personalised recommendations
- **Financial Risk and Fraud Detection** banks use Snowparks real time ML capabilities to score transactioons as they occur. Document AI processes loan applications. Cortex Search enables compliance t[...]
- **Healthcare and Life Sciences** Document AI used to extract data from clinical notes and research papers. ML models used to identify patients at risk of specific conditions
- **Supply Chain Optimisation** Predictive models used over sensor data on equipment to predict failure. Cortex Analyst to ask about inventory levels in natural language
- **Marketing and COntent Analysis** Media companies use Cortex AI SQL to analyse social media responses and content performance. Document AI processess contracts to ensure compliance
