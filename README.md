# Data Warehouse Project — Medallion Architecture (PostgreSQL)

A data warehouse implementation using the **medallion architecture** (Bronze → Silver → Gold) to integrate CRM and ERP source data into a dimensional model ready for business analytics.

---

## Architecture Overview

```
Source Systems                Bronze Layer         Silver Layer          Gold Layer
──────────────               ─────────────        ─────────────         ──────────
CRM (CSV files)  ──COPY──►  Raw tables      ──►  Cleaned tables  ──►  Dim/Fact views
ERP (CSV files)  ──COPY──►  (no transforms)      (standardized)        (star schema)
```

| Layer  | Schema   | Purpose |
|--------|----------|---------|
| Bronze | `bronze` | Raw ingestion — no transformations, exact copy of source CSVs |
| Silver | `silver` | Cleaned, standardized, deduplicated data |
| Gold   | `gold`   | Business-ready dimensional model exposed as views |

---

## Project Structure

```
myproject_DWH/
├── datasets/
│   ├── source_crm/               # CRM source files
│   │   ├── cust_info.csv         # Customer master data
│   │   ├── prd_info.csv          # Product master data
│   │   └── sales_details.csv     # Sales transactions
│   └── source_erp/               # ERP source files
│       ├── CUST_AZ12.csv         # Customer supplementary attributes
│       ├── LOC_A101.csv          # Location / country data
│       └── PX_CAT_G1V2.csv       # Product categories
└── scripts/
    ├── 00_createDatabse.sql       # Database & schema setup
    ├── bronze/
    │   ├── 00_ddl_bronze.sql      # Bronze table definitions
    │   └── 01_load_data.sql       # Stored procedure: bulk load from CSV
    ├── silver/
    │   ├── 00_ddl_silver.sql      # Silver table definitions
    │   ├── 01_checking_data_quality.sql  # Data quality validation queries
    │   └── 02_cleaning_data.sql   # Stored procedure: clean & transform
    └── gold/
        └── ddl_gold.sql           # Dimension & fact view definitions
```

---

## Data Sources

### CRM
| File | Description |
|------|-------------|
| `cust_info.csv` | Customer ID, key, name, marital status, gender, create date |
| `prd_info.csv` | Product ID, key, name, cost, product line, validity dates |
| `sales_details.csv` | Order number, product/customer keys, order/ship/due dates, amount, quantity, price |

### ERP
| File | Description |
|------|-------------|
| `CUST_AZ12.csv` | Supplementary customer attributes: birthdate, gender |
| `LOC_A101.csv` | Customer country/location codes |
| `PX_CAT_G1V2.csv` | Product category and subcategory hierarchy |

---

## Gold Layer — Dimensional Model

```
         dim_customers                fact_sales               dim_products
         ─────────────               ──────────               ────────────
         customer_key  ◄────────── customer_key
                                     product_key ───────────► product_key
                                     order_number
                                     order_date
                                     ship_date
                                     due_date
                                     sales_amount
                                     quantity
                                     price
```

**Views**:
- `gold.dim_customers` — unified customer profile (CRM + ERP enrichment)
- `gold.dim_products` — current products with category hierarchy (historical records excluded)
- `gold.fact_sales` — sales transactions linked to both dimensions

---

## Key Transformations (Bronze → Silver)

| Table | Transformations Applied |
|-------|------------------------|
| CRM Customers | TRIM whitespace, decode gender (`F/M → Female/Male`), decode marital status (`S/M → Single/Married`), deduplicate (keep latest record per customer key) |
| CRM Products | Extract category ID from product key, decode product line codes, fix invalid end dates via window functions |
| CRM Sales | Convert 8-digit integer dates to `DATE`, recalculate incorrect sales amounts (`quantity × price`), fill missing prices |
| ERP Customers | Strip `NAS` prefix from IDs, filter out future birth dates |
| ERP Locations | Remove dashes from IDs, normalize country codes (`DE → Germany`, `US/USA → United States`) |

---

## Getting Started

### Prerequisites
- PostgreSQL 13+
- `psql` CLI or VS Code with the [SQL Tools extension](https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools)

### Setup

1. **Create database and schemas**
   ```sql
   -- run scripts/00_createDatabse.sql
   -- creates: database 'datawarehouse', schemas: bronze, silver, gold
   ```

2. **Create Bronze tables**
   ```sql
   -- run scripts/bronze/00_ddl_bronze.sql
   ```

3. **Load raw data into Bronze**
   ```sql
   -- update CSV file paths in the script if needed, then:
   CALL bronze.load_bronze();
   ```

4. **Create Silver tables**
   ```sql
   -- run scripts/silver/00_ddl_silver.sql
   ```

5. **Clean and transform into Silver**
   ```sql
   CALL silver.load_silver();
   ```

6. **Create Gold views**
   ```sql
   -- run scripts/gold/ddl_gold.sql
   ```
---

## Tech Stack

- **Database**: PostgreSQL
- **Scripting**: PL/pgSQL (stored procedures with error handling and load-time logging)
- **SQL Features**: Window functions, CASE expressions, type casting, CTEs, bulk COPY
- **IDE**: VS Code + SQL Tools extension
- **Source Format**: CSV (UTF-8, comma-delimited)
