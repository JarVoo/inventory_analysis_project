{{ config(materialized='table') }}

WITH product_sales AS (

SELECT
  product_id,
  product_name,
  category,
  AVG(units_sold) AS avg_daily_units_sold,
  SUM(units_sold) AS total_units_sold,
  COUNT(DISTINCT date) AS days_with_sales
FROM {{ ref('core_daily_sales') }}
JOIN {{ source('raw', 'dim_product_master') }} USING (product_id)
GROUP BY product_id, product_name, category
)

SELECT *,
   CASE WHEN avg_daily_units_sold > AVG(avg_daily_units_sold) OVER() THEN 'High Velocity'
   WHEN avg_daily_units_sold < AVG(avg_daily_units_sold) OVER() THEN 'Low Velocity'
   ELSE 'Average Velocity'
END AS velocity_segment
FROM product_sales
ORDER BY avg_daily_units_sold DESC
