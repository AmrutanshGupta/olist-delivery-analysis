-- Question: Worst Sellers Per State
-- Technique: CTE, RANK
-- Output columns: primary_seller_id, primary_seller_state, orders, late_orders, late_rate_pct, avg_review, rank_in_state

WITH seller_stats AS (
  SELECT primary_seller_id, primary_seller_state,
         COUNT(*) AS orders,
         SUM(is_late) AS late_orders,
         ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_rate_pct,
         ROUND(AVG(review_score), 2) AS avg_review
  FROM order_facts
  WHERE primary_seller_id IS NOT NULL
  GROUP BY primary_seller_id, primary_seller_state
  HAVING COUNT(*) >= 30
),
ranked AS (
  SELECT *,
         RANK() OVER (PARTITION BY primary_seller_state
                      ORDER BY late_rate_pct DESC, orders DESC) AS rank_in_state
  FROM seller_stats
)
SELECT * FROM ranked WHERE rank_in_state <= 3
ORDER BY primary_seller_state, rank_in_state;
