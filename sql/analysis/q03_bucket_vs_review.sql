-- Question: Bucket vs Review
-- Technique: Window functions, conditional aggregation
-- Output columns: delay_bucket, bucket_order, orders, share_pct, avg_review, pct_1_star, pct_5_star, reviewed_orders

SELECT
  delay_bucket,
  bucket_order,
  COUNT(*) AS orders,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS share_pct,
  ROUND(AVG(review_score), 2) AS avg_review,
  ROUND(100.0 * SUM(CASE WHEN review_score = 1 THEN 1 ELSE 0 END) / COUNT(review_score), 2) AS pct_1_star,
  ROUND(100.0 * SUM(CASE WHEN review_score = 5 THEN 1 ELSE 0 END) / COUNT(review_score), 2) AS pct_5_star,
  COUNT(review_score) AS reviewed_orders
FROM order_facts
GROUP BY delay_bucket, bucket_order
ORDER BY bucket_order;
