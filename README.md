# 🏪 End-to-End Retail Data Pipeline

[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue)](https://github.com/Suprathika-vangari/e2e-retail-data-pipeline/actions)
[![dbt](https://img.shields.io/badge/dbt-1.0+-orange)](https://www.getdbt.com/)
[![Airflow](https://img.shields.io/badge/Airflow-2.9.3-green)](https://airflow.apache.org/)

> A production-grade data engineering pipeline that processes **1M+ retail transactions** with automated orchestration, incremental loading, and data quality testing.

---

## 📊 Project Highlights

| Metric | Value |
|--------|-------|
| **Processing Volume** | 1M+ transactions (45MB raw data) |
| **Pipeline Runtime** | 5 min (incremental) / 35 min (full refresh) |
| **Performance Gain** | 90% faster with incremental strategy |
| **Data Quality Tests** | 9 automated validations |
| **Schedule** | Daily at 02:00 UTC |
| **CI/CD** | Automated testing on every commit |

---

## 🏗️ Architecture

\\\
┌─────────────────────────────────────────────────────────────────┐
│                      ORCHESTRATION LAYER                         │
│                    Apache Airflow (Scheduler)                    │
└────────────────────────┬────────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
    ┌────────┐     ┌─────────┐     ┌────────┐
    │  Seed  │────▶│   Run   │────▶│  Test  │
    │  (5min)│     │ (25min) │     │ (3min) │
    └────────┘     └─────────┘     └────────┘
         │               │               │
         └───────────────┼───────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    TRANSFORMATION LAYER (dbt)                    │
├─────────────────────────────────────────────────────────────────┤
│  Raw Layer          │  Staging Layer    │  Core Layer           │
│  ───────────        │  ──────────────   │  ──────────           │
│  online_retail.csv ─▶ stg_online_retail ─▶ dim_customer        │
│  (Source Data)      │  (Cleaned)        │  fact_sales          │
│                     │                   │  (Incremental)        │
└─────────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      STORAGE LAYER                               │
│                    PostgreSQL Database                           │
│   ┌──────────┐          ┌─────────────────────┐                │
│   │   raw    │          │        core         │                │
│   │ (staging)│          │ (star schema)       │                │
│   └──────────┘          └─────────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
\\\

---

## 🎯 Key Features

### ⚡ Performance Optimization
- **Incremental Loading:** Only processes new records after last run date
- **Date-based Partitioning:** Filters on \order_date > MAX(order_date)\
- **Result:** 90% reduction in processing time for daily updates

### ✅ Data Quality
- **9 Automated Tests:** Not-null, uniqueness, referential integrity
- **Test Coverage:** All critical fields and relationships validated
- **Execution:** Tests run automatically after every transformation

### 🤖 CI/CD Pipeline
- **GitHub Actions:** Automated testing on every push/PR
- **Test Environment:** Spins up Postgres container for validation
- **Workflow:** Seed → Run → Test → Generate Docs

### 📦 Containerization
- **Docker Compose:** Single command to spin up entire stack
- **Services:** Postgres database + Airflow webserver/scheduler
- **Portability:** Runs identically on any machine with Docker

---

## 📁 Project Structure

\\\
e2e-retail-data-pipeline/
│
├── .github/
│   └── workflows/
│       └── dbt-ci.yml              # CI/CD pipeline definition
│
├── airflow/
│   └── dags/
│       └── retail_etl_dbt_dag.py   # Orchestration DAG (3 tasks)
│
├── dbt_project/
│   ├── models/
│   │   ├── staging/
│   │   │   └── stg_online_retail.sql    # Staging transformations
│   │   └── core/
│   │       ├── dim_customer.sql         # Customer dimension
│   │       ├── fact_sales.sql           # Sales fact (incremental)
│   │       └── schema.yml               # Data quality tests
│   ├── seeds/
│   │   └── online_retail_II.csv         # Source dataset (45MB)
│   └── dbt_project.yml                   # dbt configuration
│
├── .dbt/
│   └── profiles.yml                      # Database connection config
│
├── docker-compose.yml                    # Infrastructure as Code
└── README.md
\\\

---

## 🚀 Quick Start

### Prerequisites
- Docker Desktop installed and running
- Python 3.8+ (for local dbt development)

### 1. Clone and Navigate
\\\ash
git clone https://github.com/Suprathika-vangari/e2e-retail-data-pipeline.git
cd e2e-retail-data-pipeline
\\\

### 2. Start Infrastructure
\\\ash
docker-compose up -d
\\\

Wait 2-3 minutes for services to initialize.

### 3. Access Airflow UI
- **URL:** http://localhost:8080
- **Username:** \dmin\
- **Password:** \dmin\

### 4. Trigger Pipeline
1. Toggle the DAG to **ON** (enable)
2. Click the **▶ Play** button to trigger manual run
3. Monitor progress in the Grid view

### 5. Verify Results
\\\ash
# Connect to Postgres
docker exec -it retail_postgres psql -U retail_user -d retail_db

# Query transformed data
SELECT COUNT(*) FROM core.fact_sales;
SELECT COUNT(*) FROM core.dim_customer;
\\\

---

## 📈 Data Models

### Source Layer
| Table | Description | Records |
|-------|-------------|---------|
| \online_retail_II\ | Raw transaction data (2009-2011) | 1M+ |

### Staging Layer
| Model | Type | Description |
|-------|------|-------------|
| \stg_online_retail\ | View | Cleaned column names, null filtering |

### Core Layer (Star Schema)
| Model | Type | Strategy | Description |
|-------|------|----------|-------------|
| \dim_customer\ | Table | Full Refresh | Unique customers with country |
| \act_sales\ | Table | **Incremental** | Transaction-level sales with metrics |

---

## 🧪 Data Quality Tests

| Test Type | Coverage | Purpose |
|-----------|----------|---------|
| **Not Null** | 6 columns | Ensures critical fields are populated |
| **Unique** | \customer_id\ | Validates primary key integrity |
| **Relationships** | \act_sales.customer_id\ → \dim_customer.customer_id\ | Enforces referential integrity |

**Test Execution:**
\\\ash
cd dbt_project
dbt test --profiles-dir ../.dbt
\\\

---

## 💡 Sample Analytics Queries

### Top 10 Customers by Revenue
\\\sql
SELECT 
    c.customer_id,
    c.country,
    SUM(f.total_value) AS total_revenue,
    COUNT(DISTINCT f.invoice_no) AS num_orders
FROM core.fact_sales f
JOIN core.dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.country
ORDER BY total_revenue DESC
LIMIT 10;
\\\

### Monthly Sales Trend
\\\sql
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(DISTINCT invoice_no) AS num_orders,
    SUM(total_value) AS monthly_revenue,
    AVG(total_value) AS avg_order_value
FROM core.fact_sales
GROUP BY month
ORDER BY month;
\\\

### Top Products by Country
\\\sql
SELECT 
    c.country,
    f.description AS product,
    SUM(f.quantity) AS units_sold,
    SUM(f.total_value) AS revenue
FROM core.fact_sales f
JOIN core.dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.country, f.description
QUALIFY ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY revenue DESC) <= 5;
\\\

---

## 🛠️ Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Orchestration** | Apache Airflow 2.9.3 | Workflow scheduling and monitoring |
| **Transformation** | dbt Core + dbt-postgres | SQL-based ELT transformations |
| **Database** | PostgreSQL 13 | Data warehouse |
| **Containerization** | Docker + Docker Compose | Infrastructure as Code |
| **CI/CD** | GitHub Actions | Automated testing |
| **Version Control** | Git | Source code management |

---

## 🔄 Pipeline Workflow

### DAG Tasks
1. **dbt_seed** (5-7 min)
   - Loads CSV into \aw.online_retail_II\ table
   - Truncates and reloads on each run

2. **dbt_run** (20-25 min full / 3-5 min incremental)
   - Executes staging transformations
   - Builds dimension tables
   - Incrementally updates fact table

3. **dbt_test** (2-3 min)
   - Validates not-null constraints
   - Checks uniqueness and relationships
   - Fails pipeline if tests don't pass

### Incremental Strategy
\\\sql
-- fact_sales.sql (simplified)
{{ config(materialized='incremental', unique_key='invoice_no') }}

SELECT * FROM {{ ref('stg_online_retail') }}

{% if is_incremental() %}
  WHERE order_date > (SELECT MAX(order_date) FROM {{ this }})
{% endif %}
\\\

---

## 📊 Performance Benchmarks

| Scenario | Full Refresh | Incremental | Improvement |
|----------|--------------|-------------|-------------|
| **Initial Load** | 35 min | N/A | Baseline |
| **Daily Update (1 day data)** | 35 min | 3 min | **91% faster** |
| **Weekly Update (7 days data)** | 35 min | 5 min | **86% faster** |

---

## 🎓 Learning Outcomes

This project demonstrates:

- ✅ **ELT Design Patterns:** Staging → Core transformation layers
- ✅ **Dimensional Modeling:** Star schema with facts and dimensions
- ✅ **Performance Optimization:** Incremental loading strategies
- ✅ **Data Quality Engineering:** Automated testing frameworks
- ✅ **Workflow Orchestration:** DAG design and task dependencies
- ✅ **Infrastructure as Code:** Dockerized environments
- ✅ **DevOps Practices:** CI/CD pipelines and version control

---

## 🚀 Future Enhancements

- [ ] **Monitoring:** Add Slack/email alerts for pipeline failures
- [ ] **Visualization:** Build Metabase/Superset dashboard
- [ ] **Cloud Migration:** Deploy to Snowflake/Databricks/BigQuery
- [ ] **Advanced Modeling:** Implement SCD Type 2 for slowly changing dimensions
- [ ] **Data Lineage:** Generate and host dbt docs site
- [ ] **Streaming:** Add Kafka for real-time event processing

---

## 👤 Author

**Suprathika Vangari**  
Data Engineer

[![GitHub](https://img.shields.io/badge/GitHub-Profile-black?logo=github)](https://github.com/Suprathika-vangari)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://www.linkedin.com/in/suprathika-vangari)

---

## 📄 License

MIT License - Feel free to use this project for learning and portfolio purposes.

---

## 🙏 Acknowledgments

- **Dataset:** [Online Retail II Dataset](https://www.kaggle.com/datasets/lakshmi25npathi/online-retail-dataset) from Kaggle
- **Tools:** Apache Airflow, dbt Labs, PostgreSQL, Docker
