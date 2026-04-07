{{ config(materialized='table') }}

WITH avg_daily_sales AS (
SELECT 
    product_id,
    AVG(units_sold) AS avg_daily_units_sold
FROM {{ ref('core_daily_sales') }} AS s
GROUP BY product_id

),

forecast_accuracy AS (
    SELECT
    s.product_id,
    AVG(demand_forecast) AS avg_forecast,
    AVG(units_sold) AS avg_actual
    FROM {{ ref('core_daily_sales') }} AS s
    JOIN {{ ref('core_inventory_snapshot') }} AS i 
    USING (date, product_id, store_id)
    GROUP BY s.product_id

)

SELECT 
    s.product_id,
    p.product_name,
    p.category,
    avg_daily_units_sold * p.lead_time_days AS suggested_reorder_point,
    p.reorder_point,
    avg_forecast,
    avg_actual,
    ROUND((avg_actual - avg_forecast) / avg_forecast * 100, 2) AS forecast_accuracy_percentage,
    (avg_daily_units_sold * p.lead_time_days) - p.reorder_point AS reorder_point_gap
FROM avg_daily_sales AS s
JOIN forecast_accuracy AS f 
USING (product_id)
JOIN {{ source('raw', 'dim_product_master') }} AS p 
USING (product_id)


    