{{ config(materialized='table') }}

WITH inventory_health AS (
    SELECT
        store_id,
        AVG(stockout_rate) AS avg_stockout_rate,
        AVG(overstock_rate) AS avg_overstock_rate
    FROM {{ ref('mart_inventory_health') }}
    GROUP BY store_id
),

revenue_loss AS (
    SELECT
        store_id,
        SUM(estimated_revenue_loss) AS total_revenue_loss
    FROM {{ ref('mart_stockout_revenue_loss') }}
    GROUP BY store_id
),

cash_exposure AS (
    SELECT
        store_id,
        SUM(cash_tied_up) AS total_cash_exposure
    FROM {{ ref('mart_overstock_cash_exposure') }}
    GROUP BY store_id
),

turnover AS (
    SELECT
        store_id,
        AVG(inventory_turnover) AS avg_inventory_turnover
    FROM {{ ref('mart_inventory_turnover') }}
    GROUP BY store_id
)

SELECT
    ih.store_id,
    ROUND(ih.avg_stockout_rate, 2) AS avg_stockout_rate,
    ROUND(ih.avg_overstock_rate, 2) AS avg_overstock_rate,
    ROUND(rl.total_revenue_loss, 2) AS total_revenue_loss,
    ROUND(ce.total_cash_exposure, 2) AS total_cash_exposure,
    ROUND(t.avg_inventory_turnover, 2) AS avg_inventory_turnover,
    RANK() OVER (ORDER BY ih.avg_stockout_rate ASC) AS stockout_rank,
    RANK() OVER (ORDER BY ih.avg_overstock_rate ASC) AS overstock_rank,
    RANK() OVER (ORDER BY rl.total_revenue_loss ASC) AS revenue_loss_rank,
    RANK() OVER (ORDER BY ce.total_cash_exposure ASC) AS cash_exposure_rank,
    RANK() OVER (ORDER BY t.avg_inventory_turnover DESC) AS turnover_rank,
    ROUND((
        RANK() OVER (ORDER BY ih.avg_stockout_rate ASC) +
        RANK() OVER (ORDER BY ih.avg_overstock_rate ASC) +
        RANK() OVER (ORDER BY rl.total_revenue_loss ASC) +
        RANK() OVER (ORDER BY ce.total_cash_exposure ASC) +
        RANK() OVER (ORDER BY t.avg_inventory_turnover DESC)
    ) / 5.0, 1) AS overall_performance_score
FROM inventory_health AS ih
JOIN revenue_loss AS rl USING (store_id)
JOIN cash_exposure AS ce USING (store_id)
JOIN turnover AS t USING (store_id)
ORDER BY overall_performance_score ASC