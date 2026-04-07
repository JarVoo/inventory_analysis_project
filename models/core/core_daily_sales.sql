{{ config(materialized='view') }}

SELECT
    transaction_id,
    CAST(date AS DATE) AS date,
    store_id,
    product_id,
    units_sold,
    CAST(unit_price AS DECIMAL(10, 2)) AS unit_price,
    discount_pct,
    CAST(is_holiday_promo AS BOOLEAN) AS is_holiday_promo,
    weather_condition,
    seasonality,
    CAST(competitor_price AS DECIMAL(10, 2)) AS competitor_price,
    CAST(gross_revenue AS DECIMAL(10, 2)) AS gross_revenue,
    CAST(net_revenue AS DECIMAL(10, 2)) AS net_revenue
FROM {{ source('raw', 'fct_daily_sales') }} AS daily_sales