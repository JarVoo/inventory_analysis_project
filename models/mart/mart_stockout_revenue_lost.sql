{{ config(materialized='table') }}

WITH avg_daily_sales AS (
SELECT
    product_id,
    store_id,
    AVG(units_sold) AS avg_units_sold,
    AVG(unit_price) AS avg_unit_price
FROM {{ ref('core_daily_sales') }}
GROUP BY 1,2

),

stockout_days AS (

SELECT 
    product_id,
    product_name,
    category,
    store_id,
    total_stockout_days
FROM {{ ref('mart_inventory_health') }}
)

SELECT
    ds.store_id,
    sd.product_name,
    sd.category,
    ROUND((total_stockout_days * avg_units_sold * avg_unit_price),1) AS estimated_stockout_revenue_loss
FROM avg_daily_sales AS ds
JOIN stockout_days AS sd
USING(product_id,store_id)