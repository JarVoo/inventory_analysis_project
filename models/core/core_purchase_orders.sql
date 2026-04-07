{{ config(materialized='view') }}

SELECT
    po_id,
    CAST(order_date AS DATE) AS order_date,
    CAST(expected_receipt_date AS DATE) AS expected_receipt_date,
    store_id,
    product_id,
    supplier_id,
    CAST(qty_ordered AS INT) AS qty_ordered,
    CAST(unit_cost AS DECIMAL(10, 2)) AS unit_cost,
    CAST(total_order_value AS DECIMAL(10, 2)) AS total_order_value,
    CAST(lead_time_days AS INT) AS lead_time_days,
    status,
    DATEDIFF(day, order_date, expected_receipt_date) AS planned_lead_time
FROM {{ source('raw', 'fct_purchase_orders') }} AS purchase_orders