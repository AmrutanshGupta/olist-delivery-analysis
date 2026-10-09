-- Question: Monthly Trend
-- Technique: Window function, rolling average
-- Output columns: purchase_month, orders, late_orders, on_time_pct, avg_review, on_time_pct_3m_avg

WITH monthly AS (
  SELECT purchase_month,
         COUNT(*) AS orders,
         SUM(is_late) AS late_orders,
         ROUND(100.0 * SUM(on_time_flag) / COUNT(*), 2) AS on_time_pct,
         ROUND(AVG(review_score), 3) AS avg_review
  FROM order_facts
  GROUP BY purchase_month
)
SELECT *,
       ROUND(AVG(on_time_pct) OVER (
         ORDER BY purchase_month
         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS on_time_pct_3m_avg
FROM monthly
ORDER BY purchase_month;
