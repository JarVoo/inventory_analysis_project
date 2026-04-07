{{ config(materialized='table') }}

SELECT
    p.product_id,
    p.product_name,
    p.category,
    i.store_id,
    SUM(CAST(is_stockout AS INT)) AS total_stockout_days,
    (SUM(CAST(is_stockout AS INT)) / COUNT(*))*100 AS stockout_rate,
    SUM(CAST(is_overstock AS INT)) AS total_overstock_days,
    (SUM(CAST(is_overstock AS INT)) / COUNT(*))*100 AS overstock_rate,
    ROUND(AVG(days_of_supply),2) AS avg_days_of_supply,
    ROUND(AVG(closing_stock),2) AS avg_closing_stock
FROM {{ ref('core_inventory_snapshot') }} AS i
JOIN {{ source('raw', 'dim_product_master') }} AS p USING (product_id)
GROUP BY p.product_id, p.product_name, p.category, i.store_id
ORDER BY stockout_rate DESC, overstock_rate DESC, avg_days_of_supply ASC

