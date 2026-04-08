## Introduction

Retailers face two costly inventory problems simultaneously, stock that sits unsold tying up cash, and stock that runs out before replenishment arrives losing sales. This project builds a full analytical pipeline to identify which products are affected, quantify the impact, and surface data-driven reorder recommendations. All of this is created in an end-to-end workflow, data is ingested via S3, and stored in Snowflake. The data is transformed in dbt, documentation recorded, and testing procedures put in place to export to Power BI where stockout rates, overstock patterns, inventory turnover, and reorder gaps are visualised in a single operational dashboard.

# Problem Statement

Let me explain where retailers get caught, too little stock (stockout), and too much stock (overstock):

Too little stock:

1) Lost sales when the customer wants the item, but the shelf is empty, so the customer shops elsewhere.
2) When repeat customers who cant get a repeat order, chooses another company to get their goods.
3) When you need to recover the gap in stock, so you pay a higher cost for faster shipping or inflated costs at short notice.

Too much stock:

1) Cash tied up in products that are not moving off the shelf.
2) Markdowns and/or discounts needed to clear away this stock.
3) If goods are perishable or seasonal, they may need to be thrown away completely, wasting money.
4) Storage costs accumulate on slow-moving items

These two errors often have the same root cause, reorder points and demand forecasts that dont reflect actual sales patterns. You order too late and run out, or you over-correct and order too much.

## Architecture

![dbt Lineage Graph](assets/dbt-lineage.png)

Data flows through three layers:

- **RAW** — source tables loaded directly from S3 into Snowflake via COPY INTO. No transformations applied.
- **CORE** — one view per source table. Casts data types, adds boolean flags, and derives basic fields. Built as views so they always reflect current RAW data.
- **MART** — aggregated tables built on CORE models. Each mart answers a specific business question and is materialised as a table for query performance.

## Tech Stack

| Tool | Purpose |
|------|---------|
| Amazon S3 | Cloud storage — raw CSV file landing zone |
| Snowflake | Cloud data warehouse — RAW, CORE, and MART layers |
| dbt Core | Transformation, testing, and documentation |
| Power BI | Dashboard and visualisation layer |
| Git & GitHub | Version control |

## Data Model

### RAW Layer — Source Tables

| Table | Description |
|-------|-------------|
| `dim_product_master` | Dimension table containing all unique products, their categories, suppliers, unit cost, base price, reorder points, reorder quantities, and supplier lead times. |
| `fct_daily_sales` | Daily sales transactions across all stores. Contains transaction ID, date, store, units sold, unit price, discounts applied, weather conditions, seasonality, competitor pricing, gross revenue, and net revenue. |
| `fct_inventory_snapshot` | Daily stock level snapshot per product per store. Contains opening and closing stock, units ordered, demand forecast, days of supply, and inventory value. |
| `fct_purchase_orders` | Supplier-facing purchase order records. Contains order and expected receipt dates, quantities ordered, unit cost, total order value, supplier ID, and order status (PENDING or RECEIVED). |

### CORE Layer — Cleaned Source Tables (Views)

| Model | Description |
|-------|-------------|
| `core_inventory_snapshot` | Cleans and types the raw inventory snapshot. Casts date strings to DATE, integer flags to BOOLEAN, and currency columns to DECIMAL(10,2). Serves as the foundation for inventory health and reorder analysis. |
| `core_daily_sales` | Cleans and types the raw sales data. Casts date strings to DATE, holiday promo flag to BOOLEAN, and price/revenue columns to DECIMAL(10,2). Primary source for velocity and turnover analysis. |
| `core_purchase_orders` | Cleans and types the raw purchase order data. Adds a derived `planned_lead_time` column calculated from order and expected receipt dates. Not consumed by any MART model in this project — retained as a foundation for future supplier performance analysis. |

### MART Layer — BI-Ready Aggregated Tables

| Model | Description |
|-------|-------------|
| `mart_product_velocity` | Classifies products as High or Low Velocity based on average daily units sold relative to the overall product average. Identifies fast and slow movers across the catalogue. |
| `mart_inventory_health` | Calculates stockout and overstock rates per product per store as a percentage of total trading days. Surfaces which product-store combinations have the most critical inventory imbalances. |
| `mart_inventory_turnover` | Measures how efficiently stock is converted to sales by comparing average daily COGS against average daily inventory value. A ratio below 1.0 indicates stock is not moving fast enough relative to holding costs. |
| `mart_reorder_analysis` | Compares current reorder points against data-driven suggestions based on actual average daily demand multiplied by supplier lead time. Also validates demand forecast accuracy against actual sales. |