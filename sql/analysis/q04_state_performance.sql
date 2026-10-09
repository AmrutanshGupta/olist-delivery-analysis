-- Question: State Performance
-- Technique: Aggregation, HAVING
-- Output columns: customer_state, orders, late_orders, late_rate_pct, avg_review, avg_promised_days, avg_actual_days, avg_days_late_when_late

SELECT
  customer_state,
  COUNT(*) AS orders,
  SUM(is_late) AS late_orders,
  ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_rate_pct,
  ROUND(AVG(review_score), 2) AS avg_review,
  ROUND(AVG(promised_days), 2) AS avg_promised_days,
  ROUND(AVG(actual_days), 2) AS avg_actual_days,
  ROUND(AVG(CASE WHEN is_late = 1 THEN delay_days END), 2) AS avg_days_late_when_late
FROM order_facts
GROUP BY customer_state
HAVING COUNT(*) >= 100;
