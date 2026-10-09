-- Question: Category Performance
-- Technique: Aggregation, HAVING
-- Output columns: category, orders, late_rate_pct, avg_review

SELECT
  category,
  COUNT(*) AS orders,
  ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS late_rate_pct,
  ROUND(AVG(review_score), 2) AS avg_review
FROM order_facts
GROUP BY category
HAVING COUNT(*) >= 300;
