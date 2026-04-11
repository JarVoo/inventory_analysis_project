{{ config(materialized='table') }}

WITH finding_cogs AS (
SELECT 
    s.product_id, 
    p.product_name,
    SUM(p.unit_cost * s.units_sold) AS cogs,
    SUM(s.net_revenue) AS net_revenue
FROM {{ ref('core_daily_sales') }} AS s
JOIN {{ source('raw', 'dim_product_master') }} AS p
USING(product_id)
GROUP BY 1,2
),

finding_margin AS (

SELECT 
    product_id,
    product_name,
    (net_revenue - cogs) / net_revenue * 100 AS product_margin
FROM finding_cogs
),

margin_calc AS (

SELECT 
    product_id,
    product_name,
    product_margin,
    CASE 
        WHEN product_margin > AVG(product_margin) OVER() THEN 'High Margin'
        ELSE 'Low Margin'
        END AS margin_segment
FROM finding_margin

)

SELECT 
    mc.product_id,
    mc.product_name,
    mc.product_margin,
    CONCAT(mc.margin_segment, '/', pv.velocity_segment) AS quadrant
FROM margin_calc AS mc
JOIN {{ ref('mart_product_velocity') }} AS pv
USING(product_id)