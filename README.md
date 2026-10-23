# Olist Brazilian E-commerce Analysis

## Project Overview

This project analyzes the Brazilian e-commerce marketplace Olist to evaluate sales performance, operational efficiency, customer satisfaction, and delivery outcomes.

Using SQL and Power BI, the project transforms raw e-commerce data into structured business insights to support data-driven decision-making.

## Business Objectives

- Analyze sales trends and revenue performance.
- Evaluate order status, payment methods, and product performance.
- Assess delivery performance and its relationship with customer satisfaction.
- Identify operational patterns and opportunities for improvement.
- Build interactive dashboards to communicate findings to business stakeholders.

## Tools and Technologies

- **SQL (PostgreSQL):** Data exploration, validation, business analysis, and preparation of analytical views.
- **Power BI:** Data modeling, KPI development, and interactive dashboards.
- **Git and GitHub:** Version control and project documentation.

## Dashboards

### Sales Performance

Focuses on sales trends, payment methods, products, and commercial performance.

**Dashboard file:** [`Sales Dashboard (PDF)`](docs/dashboard_ventas.pdf)

### Logistics and Customer Satisfaction

Explores delivery performance, late orders, and customer review patterns.

**Dashboard file:** [`Logistics and Customer Satisfaction Dashboard (PDF)`](docs/dashboard_logistica_satisfaccion.pdf)

The Power BI report is available in [`PBI/olist.pbix`](PBI/olist.pbix).

## SQL Workflow

The SQL scripts are organized by analytical stage:

| File | Purpose |
|---|---|
| `00_esquema_y_carga.sql` | Database schema and data loading |
| `01_exploracion.sql` | Initial data exploration |
| `02_calidad_datos.sql` | Data quality checks and validation |
| `03_analisis_negocio.sql` | Business analysis queries |
| `04_modelo_bi.sql` | Preparation of analytical views for Power BI |

## Dataset

The project uses the Brazilian E-Commerce Public Dataset by Olist, available on Kaggle.

[Access the original dataset on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The raw dataset is not included in this repository. Refer to the original source to obtain the files.

## Repository Structure

```text
olist_brazilian_ecommerce_analysis/
├── PBI/
│   └── olist.pbix
├── docs/
│   ├── dashboard_ventas.pdf
│   ├── dashboard_logistica_satisfaccion.pdf
│   └── ficha_proyecto.md
└── sql/
    ├── 00_esquema_y_carga.sql
    ├── 01_exploracion.sql
    ├── 02_calidad_datos.sql
    ├── 03_analisis_negocio.sql
    └── 04_modelo_bi.sql
```

## Project Documentation

For additional context on the methodology, validation, and findings, see the [Project Brief](docs/ficha_proyecto.md).

## Author

**Albert Fabián Mendoza Mendoza**

Data Analyst | Business Intelligence | SQL | Power BI

[Portfolio](https://albert777mendoza.github.io) · [GitHub](https://github.com/albert777mendoza)
