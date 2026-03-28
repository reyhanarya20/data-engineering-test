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


