{{ config(materialized='table') }}

WITH stock_data AS (
SELECT 
    ih.product_id,
    ih.product_name,
    ih.store_id,
    ih.category,
    ih.total_overstock_days,
    GREATEST(avg_closing_stock - pm.reorder_point,0) AS excess_stock,
    pm.unit_cost,
    ih.avg_days_of_supply,
    pm.lead_time_days
FROM RETAIL_INVENTORY_DB.MART.MART_INVENTORY_HEALTH AS ih
JOIN RETAIL_INVENTORY_DB.RAW.DIM_PRODUCT_MASTER AS pm
USING(product_id)
)

SELECT 
   product_name,
   category,
   store_id,
   excess_stock * total_overstock_days * unit_cost AS cash_tied_up,
   CASE
    WHEN avg_days_of_supply < lead_time_days THEN 'Critical - stockout imminent'
    WHEN avg_days_of_supply BETWEEN lead_time_days AND lead_time_days*2 THEN 'Healthy'
    WHEN avg_days_of_supply > lead_time_days*2 THEN 'Excess - overstocked'
   END AS supply_status
FROM stock_data
ORDER BY cash_tied_up DESC