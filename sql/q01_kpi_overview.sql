-- Question: KPI Overview
-- Technique: Aggregation
-- Output columns: total_orders, late_orders, on_time_pct, avg_review_score, avg_delivery_days, avg_promised_days, unique_customers

SELECT
  COUNT(*) AS total_orders,
  SUM(is_late) AS late_orders,
  ROUND(100.0 * SUM(on_time_flag) / COUNT(*), 2) AS on_time_pct,
  ROUND(AVG(review_score), 2) AS avg_review_score,
  ROUND(AVG(actual_days), 2) AS avg_delivery_days,
  ROUND(AVG(promised_days), 2) AS avg_promised_days,
  COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM order_facts;
