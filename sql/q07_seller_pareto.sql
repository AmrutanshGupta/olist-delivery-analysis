-- Question: Seller Pareto
-- Technique: CTE, Window functions, cumulative share
-- Output columns: primary_seller_id, orders, late_orders, seller_rank, cum_pct_of_sellers, cum_pct_of_late_orders

WITH s AS (
  SELECT primary_seller_id, COUNT(*) AS orders, SUM(is_late) AS late_orders
  FROM order_facts
  WHERE primary_seller_id IS NOT NULL
  GROUP BY primary_seller_id
),
r AS (
  SELECT *,
         ROW_NUMBER() OVER (ORDER BY late_orders DESC, primary_seller_id) AS seller_rank,
         COUNT(*) OVER () AS total_sellers,
         SUM(late_orders) OVER () AS total_late
  FROM s
)
SELECT primary_seller_id, orders, late_orders, seller_rank,
       ROUND(100.0 * seller_rank / total_sellers, 2) AS cum_pct_of_sellers,
       ROUND(100.0 * SUM(late_orders) OVER (
         ORDER BY seller_rank ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) / total_late, 2) AS cum_pct_of_late_orders
FROM r
ORDER BY seller_rank;
