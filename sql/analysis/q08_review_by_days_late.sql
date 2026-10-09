-- Question: Review by Days Late
-- Technique: CASE, Aggregation
-- Output columns: days_vs_estimate, orders, avg_review

SELECT
  CASE WHEN delay_days < -10 THEN -10
       WHEN delay_days > 15 THEN 15
       ELSE delay_days END AS days_vs_estimate,
  COUNT(*) AS orders,
  ROUND(AVG(review_score), 2) AS avg_review
FROM order_facts
GROUP BY days_vs_estimate
HAVING COUNT(*) >= 30
ORDER BY days_vs_estimate;
