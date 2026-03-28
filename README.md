# Data Engineering Test - Maju Jaya

## Overview
This project demonstrates a simple data pipeline that ingests, cleans, and transforms data into a MySQL-based data warehouse.

The pipeline processes daily CSV files and organizes data into a structured warehouse with raw, staging, and datamart layers.

---

## Tech Stack
- Python (pandas, SQLAlchemy)
- MySQL (Docker)
- Docker Compose

---

## Architecture
![Architecture](diagram.png)

The pipeline follows a layered data warehouse architecture:

- **Raw Layer** → stores original data
- **Staging Layer** → handles data cleaning & transformation
- **Datamart Layer** → provides aggregated data for analysis

---

## Project Structure

data-engineering-test/
│
├── data/
│ └── customer_addresses_*.csv
│
├── python/
│ └── ingest_customer_addresses.py
│
├── sql/
│ ├── create_clean_views.sql
│ ├── create_datamart.sql
│ └── insert_datamart.sql
│
├── docker-compose.yml
├── diagram.png
├── README.md



---

## How to Run

### 1. Start MySQL (Docker)

docker-compose up -d


---

### 2. Run Data Ingestion

python python/ingest_customer_addresses.py


This script:
- Detects the latest CSV file
- Loads data into `customer_addresses_raw`
- Uses incremental append strategy

---

### 3. Run SQL Transformations


---

## Data Pipeline Flow

CSV File
↓
Python Ingestion
↓
Raw Tables (MySQL)
↓
Staging Layer (SQL Views)
↓
Datamart Tables


---

## Key Features

- Incremental ingestion from daily CSV files
- Data cleaning and normalization using SQL
- Layered data warehouse design (raw → staging → datamart)
- Containerized MySQL environment using Docker
- Modular and scalable pipeline design

---

## Data Cleaning Highlights

- Standardized date formats (multiple DOB formats handled)
- Removed invalid placeholder values (e.g. 1900-01-01)
- Converted price fields to numeric format
- Normalized city and province values (uppercase, trimmed)

---

## Future Improvements

- Add orchestration using Apache Airflow
- Implement data validation & quality checks
- Add logging and monitoring
- Support incremental upsert (deduplication)
- Integrate with BI tools (Looker / Tableau)

---

## Conclusion

This project demonstrates a scalable and modular approach to building a data pipeline and data warehouse system.  
The design ensures data consistency, maintainability, and readiness for real-world data engineering workflows.

---

## Author
Reyhan Arya Hermawan
