{{ config(materialized='table') }}

WITH daily_sales_with_cost AS (
    SELECT
    s.date,
    s.store_id,
    s.product_id,
    p.product_name,
    p.category,
    s.units_sold,
    p.unit_cost,
    (p.unit_cost * s.units_sold) AS cogs
    FROM {{ ref('core_daily_sales') }} AS s
    JOIN {{ source('raw', 'dim_product_master') }} AS p USING (product_id)
),

inventory_values AS (
    SELECT
        product_id,
        store_id,
        AVG(inventory_value) AS avg_inventory_value
    FROM {{ ref('core_inventory_snapshot') }} 
    GROUP BY product_id, store_id
)

SELECT
    d.product_id,
    d.product_name,
    d.category,
    d.store_id,
    AVG(d.cogs) AS avg_cogs,
    i.avg_inventory_value,
    CASE 
        WHEN i.avg_inventory_value = 0 THEN NULL
        ELSE ROUND(AVG(d.cogs) / i.avg_inventory_value, 2)
    END AS inventory_turnover
FROM daily_sales_with_cost AS d
JOIN inventory_values AS i USING (product_id, store_id)
GROUP BY d.product_id, d.product_name, d.store_id, i.avg_inventory_value, d.category
ORDER BY inventory_turnover DESC, avg_cogs DESC