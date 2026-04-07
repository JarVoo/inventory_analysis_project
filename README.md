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

![dbt Lineage Graph](assets/lineage.png)

Data flows through three layers:

- **RAW** — source tables loaded directly from S3 into Snowflake via COPY INTO. No transformations applied.
- **CORE** — one view per source table. Casts data types, adds boolean flags, and derives basic fields. Built as views so they always reflect current RAW data.
- **MART** — aggregated tables built on CORE models. Each mart answers a specific business question and is materialised as a table for query performance.