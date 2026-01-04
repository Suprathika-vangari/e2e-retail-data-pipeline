# 🏪 End-to-End Retail Data Pipeline

[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue)](https://github.com/Suprathika-vangari/e2e-retail-data-pipeline/actions) [![dbt](https://img.shields.io/badge/dbt-1.0+-orange)](https://www.getdbt.com/) [![Airflow](https://img.shields.io/badge/Airflow-2.9.3-green)](https://airflow.apache.org/)

> A production-grade data engineering pipeline processing **1M+ retail transactions** with automated orchestration, incremental loading, and comprehensive data quality testing.

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

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION LAYER                          │
│                  Apache Airflow (Scheduler)                     │
└────────────────────────┬────────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
    ┌────────┐     ┌─────────┐     ┌────────┐
    │  Seed  │ ──▶│   Run    │ ──▶│  Test  │
    │ (5min) │     │ (25min) │     │ (3min) │
    └────────┘     └─────────┘     └────────┘
         │               │               │
         └───────────────┼───────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                  TRANSFORMATION LAYER (dbt)                     │
├─────────────────────────────────────────────────────────────────┤
│  Raw Layer          │  Staging Layer    │  Core Layer           │
│  ───────────        │  ──────────────   │  ──────────           │
│  online_retail.csv ─▶ stg_online_retail ─▶ dim_customer        │
│  (Source Data)      │  (Cleaned)        │  fact_sales           │
│                     │                   │  (Incremental)        │
└─────────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      STORAGE LAYER                              │
│                    PostgreSQL Database                          │
│   ┌──────────┐          ┌─────────────────────┐                 │
│   │   raw    │          │        core         │                 │
│   │ (staging)│          │ (star schema)       │                 │
│   └──────────┘          └─────────────────────┘                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Key Features

### ⚡ Performance Optimization
- **Incremental Loading:** Processes only new records after last run date
- **Date-based Partitioning:** Filters on `order_date > MAX(order_date)`  
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
- **Docker Compose:** Single command deployment  
- **Services:** Postgres database + Airflow webserver/scheduler  
- **Portability:** Runs identically on any machine

---

## 📁 Project Structure

```
e2e-retail-data-pipeline/
│
├── .github/workflows/
│   └── dbt-ci.yml              # CI/CD pipeline
│
├── airflow/dags/
│   └── retail_etl_dbt_dag.py   # Orchestration (3 tasks)
│
├── dbt_project/
│   ├── models/
│   │   ├── staging/
│   │   │   └── stg_online_retail.sql
│   │   └── core/
│   │       ├── dim_customer.sql
│   │       ├── fact_sales.sql        # Incremental
│   │       └── schema.yml            # 9 tests
│   ├── seeds/
│   │   └── online_retail_II.csv      # 45MB source
│   └── dbt_project.yml
│
├── .dbt/
│   └── profiles.yml                  # DB connection
│
├── docker-compose.yml                # Infrastructure
└── README.md
```

---

## 🚀 Quick Start

### Prerequisites
- Docker Desktop (running)
- Python 3.8+

### Setup (3 steps)

**1. Clone Repository**
```bash
git clone https://github.com/Suprathika-vangari/e2e-retail-data-pipeline.git
cd e2e-retail-data-pipeline
```

**2. Start Services**  
```bash
docker-compose up -d
```
Wait 2-3 minutes for initialization

**3. Access Airflow**  
Open: http://localhost:8080  
Login: `admin` / `admin`

## Enable the DAG and click ▶ Play

---

## 📊 Data Models

**Source → Staging → Core**

| Layer | Model | Type | Strategy | Records |
|-------|-------|------|----------|-------|
| Raw | `online_retail_II` | Seed | Full Refresh | 1M+ |
| Staging | `stg_online_retail` | View | - | ~900K |
| Core | `dim_customer` | Table | Full Refresh | 4,372 |
| Core | `fact_sales` | Table | **Incremental** | ~900K |

### Incremental Logic (fact_sales)

```sql
{{ config(materialized='incremental', unique_key='invoice_no') }}

SELECT * FROM {{ ref('stg_online_retail') }}

{% if is_incremental() %}
  WHERE order_date > (SELECT MAX(order_date) FROM {{ this }})
{% endif %}
```

---

## 🧪 Data Quality Testing

**9 Automated Tests:**

| Test Type | Field | Purpose |
|-----------|-------|-------|
| `not_null` | `invoice_no` | Ensures transaction ID exists |
| `not_null` | `customer_id` | Validates customer reference |
| `not_null` | `quantity`, `unit_price`, `total_value` | Prevents null metrics |
| `unique` | `dim_customer.customer_id` | Ensures dimension integrity |
| `relationships` | `fact_sales.customer_id` → `dim_customer` | Foreign key validation |

**Run Tests Locally:**
```bash
cd dbt_project
dbt test --profiles-dir ../.dbt
```

---

## 📈 Sample Analytics

### Top 10 Customers by Revenue

```sql
SELECT 
    c.customer_id,
    c.country,
    SUM(f.total_value) AS revenue
FROM core.fact_sales f
JOIN core.dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.country
ORDER BY revenue DESC
LIMIT 10;
```

### Monthly Sales Trend

```sql
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(DISTINCT invoice_no) AS orders,
    SUM(total_value) AS revenue
FROM core.fact_sales
GROUP BY month
ORDER BY month;
```

---

## 🛠️ Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|-------|
| **Orchestration** | Apache Airflow 2.9.3 | Workflow scheduling |
| **Transformation** | dbt Core + dbt-postgres | ELT transformations |
| **Database** | PostgreSQL 13 | Data warehouse |
| **Containerization** | Docker + Docker Compose | Infrastructure as Code |
| **CI/CD** | GitHub Actions | Automated testing |

---

## 📊 Performance Benchmarks

| Scenario | Full Refresh | Incremental | Improvement |
|----------|--------------|-------------|-------------|
| **Initial Load** | 35 min | N/A | Baseline |
| **Daily Update (1 day)** | 35 min | 3 min | **91% faster** |
| **Weekly Update (7 days)** | 35 min | 5 min | **86% faster** |

---

## 🎓 Learning Outcomes

This project demonstrates:

✅ **ELT Design Patterns** – Staging → Core transformation layers  
✅ **Dimensional Modeling** – Star schema with facts and dimensions  
✅ **Performance Optimization** – Incremental loading strategies  
✅ **Data Quality Engineering** – Automated testing frameworks  
✅ **Workflow Orchestration** – DAG design and dependencies  
✅ **Infrastructure as Code** – Dockerized environments  
✅ **DevOps Practices** – CI/CD pipelines and version control

---

## 🚀 Future Enhancements

- **Monitoring:** Add Slack/email alerts for failures
- **Visualization:** Build Metabase/Superset dashboard
- **Cloud Migration:** Deploy to Snowflake/Databricks/BigQuery
- **Advanced Modeling:** Implement SCD Type 2 dimensions
- **Data Lineage:** Generate and host dbt docs site
- **Streaming:** Add Kafka for real-time processing

---

## 👤 Author

**Suprathika V**  
Data Engineer

[![GitHub](https://img.shields.io/badge/GitHub-Profile-black?logo=github)](https://github.com/Suprathika-vangari) [![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://www.linkedin.com/in/suprathika-vangari)

---

## 📄 License

MIT License - Feel free to use this project for learning and portfolio purposes.

---

## 🙏 Acknowledgments

- **Dataset:** [Online Retail II Dataset](https://www.kaggle.com/datasets/lakshmi25npathi/online-retail-dataset) from Kaggle  
- **Tools:** Apache Airflow, dbt Labs, PostgreSQL, Docker


