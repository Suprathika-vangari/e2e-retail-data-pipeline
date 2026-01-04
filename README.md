# End-to-End Retail Data Pipeline

## Overview
A production-ready ETL pipeline built with **Docker**, **Apache Airflow**, **dbt**, and **PostgreSQL** to process and transform 1M+ retail transactions into a star schema data warehouse optimized for analytics.

## Architecture

\\\
┌──────────────┐      ┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│  CSV Source  │  →   │  PostgreSQL  │  →   │  dbt Models  │  →   │  Star Schema │
│  (45MB data) │      │   (Raw DB)   │      │(Staging+Core)│      │   Warehouse  │
└──────────────┘      └──────────────┘      └──────────────┘      └──────────────┘
                              ↑                                            ↑
                              └────────────────────────────────────────────┘
                                        Orchestrated by Airflow
\\\

## Tech Stack
- **Orchestration:** Apache Airflow 2.9.3
- **Transformation:** dbt Core with dbt-postgres
- **Database:** PostgreSQL 13
- **Containerization:** Docker & Docker Compose
- **Dataset:** Online Retail II (1M+ transactions, 2009-2011)

## Pipeline Execution

### Performance Metrics
- **Average Run Time:** 30-35 minutes (full dataset)
- **Incremental Run Time:** ~5 minutes (daily new data only)
- **Schedule:** Daily at 02:00 UTC
- **Success Rate:** 95%+ (monitored via Airflow UI)

### Task Flow
1. **dbt_seed** (5-7 min): Loads CSV data into PostgreSQL raw schema
2. **dbt_run** (20-25 min): Executes transformations (staging → core models)
3. **dbt_test** (2-3 min): Validates data quality with 9 automated tests

### Incremental Loading Strategy
- **Initial Load:** Full dataset refresh (~40 min)
- **Daily Updates:** Only processes new records after last run date
- **Performance Gain:** 90% faster for incremental loads
- **Implementation:** Date-based filtering with \is_incremental()\ logic

## Data Models

### Staging Layer
- **stg_online_retail:** Cleaned and standardized raw retail transactions

### Core Layer (Star Schema)
- **dim_customer:** Customer dimension with country information
- **fact_sales:** Granular sales transactions with calculated metrics (incremental)

### Data Quality
- **9 automated tests:**
  - Not null constraints on critical fields
  - Uniqueness checks on primary keys
  - Referential integrity (foreign key validation)
- Tests run automatically on every pipeline execution

## Project Structure

\\\
e2e-retail-data-pipeline/
├── airflow/
│   └── dags/
│       └── retail_etl_dbt_dag.py      # Airflow DAG orchestrating pipeline
├── dbt_project/
│   ├── models/
│   │   ├── staging/
│   │   │   └── stg_online_retail.sql   # Staging transformations
│   │   └── core/
│   │       ├── dim_customer.sql        # Customer dimension
│   │       ├── fact_sales.sql          # Sales fact table (incremental)
│   │       └── schema.yml              # Data quality tests
│   ├── seeds/
│   │   └── online_retail_II.csv        # Source dataset
│   └── dbt_project.yml                  # dbt configuration
├── .dbt/
│   └── profiles.yml                     # Database connection config
├── docker-compose.yml                   # Infrastructure definition
└── README.md
\\\

## Setup Instructions

### Prerequisites
- Docker Desktop
- Python 3.8+
- dbt-core and dbt-postgres

### Quick Start

1. **Clone the repository**
\\\ash
git clone https://github.com/Suprathika-vangari/e2e-retail-data-pipeline.git
cd e2e-retail-data-pipeline
\\\

2. **Start Docker containers**
\\\ash
docker-compose up -d
\\\

3. **Access Airflow UI**
- URL: http://localhost:8080
- Username: \dmin\
- Password: \dmin\

4. **Trigger the pipeline**
- Enable the \etail_etl_dbt_dag\ DAG
- Click the play button to run manually or wait for scheduled run (daily at 2 AM)

## Key Features

✅ **Automated Orchestration:** Daily scheduled runs via Airflow  
✅ **Incremental Loading:** 90% faster processing for daily updates  
✅ **Data Quality Tests:** 9 automated tests for validation  
✅ **Scalable Architecture:** Dockerized for easy deployment  
✅ **Star Schema Design:** Optimized for analytical queries  
✅ **Version Controlled:** Full project tracked in Git  

## Sample Queries

### Top 10 Customers by Revenue
\\\sql
SELECT 
    c.customer_id,
    c.country,
    SUM(f.total_value) as total_revenue
FROM core.fact_sales f
JOIN core.dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.country
ORDER BY total_revenue DESC
LIMIT 10;
\\\

### Daily Sales Trend
\\\sql
SELECT 
    order_date,
    COUNT(DISTINCT invoice_no) as num_orders,
    SUM(total_value) as daily_revenue
FROM core.fact_sales
GROUP BY order_date
ORDER BY order_date;
\\\

## Future Enhancements

- [ ] Add Slack/email alerts for failures
- [ ] Implement data lineage tracking with dbt docs
- [ ] Create visualization dashboard (Metabase/Superset)
- [ ] Add CI/CD pipeline with GitHub Actions
- [ ] Deploy to cloud (Snowflake/Databricks/BigQuery)

## Author

**Suprathika Vangari**  
Data Engineer | [GitHub](https://github.com/Suprathika-vangari) | [LinkedIn](https://www.linkedin.com/in/suprathika-vangari)

## License

MIT License - feel free to use this project for learning and portfolio purposes.
