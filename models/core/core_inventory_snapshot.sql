{{ config(materialized='view') }}

SELECT 
    CAST(date AS DATE) AS date,
    store_id, 
    product_id,
    opening_stock,
    closing_stock,
    units_ordered,
    demand_forecast,
    reorder_point,
    lead_time_days,
    CAST(is_stockout AS BOOLEAN) AS is_stockout,
    CAST(is_overstock AS BOOLEAN) AS is_overstock,
    days_of_supply,
    CAST(inventory_value AS DECIMAL(10, 2)) AS inventory_value
FROM {{ source('raw', 'fct_inventory_snapshot') }} AS inventory_snapshot
