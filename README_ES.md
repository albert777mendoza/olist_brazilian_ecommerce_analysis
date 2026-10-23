# Análisis del comercio electrónico brasileño — Olist

## Descripción del proyecto

Este proyecto analiza el marketplace brasileño Olist para evaluar el desempeño de las ventas, la eficiencia operativa, la satisfacción del cliente y los resultados de las entregas.

Mediante SQL y Power BI, los datos originales se transforman en información estructurada para identificar patrones de negocio y respaldar la toma de decisiones basada en datos.

## Objetivos de negocio

- Analizar las tendencias de ventas y el desempeño comercial.
- Evaluar los estados de los pedidos, los medios de pago y el desempeño de los productos.
- Examinar el desempeño de las entregas y su relación con la satisfacción del cliente.
- Identificar patrones operativos y oportunidades de mejora.
- Desarrollar dashboards interactivos para comunicar hallazgos a los responsables del negocio.

## Herramientas y tecnologías

- **SQL (PostgreSQL):** exploración de datos, validación de calidad, análisis de negocio y preparación de vistas analíticas.
- **Power BI:** modelado de datos, desarrollo de indicadores clave de desempeño (KPI) y dashboards interactivos.
- **Git y GitHub:** control de versiones y documentación del proyecto.

## Dashboards

### Desempeño de ventas

Analiza las tendencias de ventas, los medios de pago, los productos y el desempeño comercial.

**Archivo del dashboard:** [Dashboard de ventas (PDF)](docs/dashboard_ventas.pdf)

### Logística y satisfacción del cliente

Examina el desempeño de las entregas, los pedidos tardíos y los patrones de las reseñas de los clientes.

**Archivo del dashboard:** [Dashboard de logística y satisfacción del cliente (PDF)](docs/dashboard_logistica_satisfaccion.pdf)

El informe de Power BI está disponible en [`PBI/olist.pbix`](PBI/olist.pbix).

## Flujo de trabajo SQL

Los scripts SQL están organizados por etapas analíticas:

| Archivo | Propósito |
|---|---|
| `00_esquema_y_carga.sql` | Definición del esquema y carga de datos |
| `01_exploracion.sql` | Exploración inicial de los datos |
| `02_calidad_datos.sql` | Controles y validaciones de calidad de datos |
| `03_analisis_negocio.sql` | Consultas de análisis de negocio |
| `04_modelo_bi.sql` | Preparación de vistas analíticas para Power BI |

## Dataset

El proyecto utiliza el conjunto de datos público **Brazilian E-Commerce Public Dataset by Olist**, disponible en Kaggle.

[Consultar el dataset original en Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

Los datos originales no están incluidos en este repositorio. Deben obtenerse directamente desde la fuente oficial indicada.

## Estructura del repositorio

```text
olist_brazilian_ecommerce_analysis/
├── PBI/
│   └── olist.pbix
├── docs/
│   ├── dashboard_ventas.pdf
│   ├── dashboard_logistica_satisfaccion.pdf
│   └── ficha_proyecto.md
├── sql/
│   ├── 00_esquema_y_carga.sql
│   ├── 01_exploracion.sql
│   ├── 02_calidad_datos.sql
│   ├── 03_analisis_negocio.sql
│   └── 04_modelo_bi.sql
├── README.md
└── README_ES.md
```

## Documentación del proyecto

Para conocer más sobre la metodología, las validaciones y los resultados del análisis, consulta la [ficha del proyecto](docs/ficha_proyecto.md).

## Autor

**Albert Fabián Mendoza Mendoza**

Data Analyst | Business Intelligence | SQL | Power BI

[Portafolio](https://albert777mendoza.github.io) · [GitHub](https://github.com/albert777mendoza)
