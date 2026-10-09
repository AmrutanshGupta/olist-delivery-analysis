-- Question: Repeat Cohort Binary
-- Technique: Window functions, self-join, cohort analysis
-- Output columns: is_late, customers, repeaters, repeat_rate_90d_pct

WITH ranked AS (
  SELECT customer_unique_id, order_id, order_purchase_timestamp AS ts,
         delay_bucket, bucket_order, is_late,
         ROW_NUMBER() OVER (PARTITION BY customer_unique_id
                            ORDER BY order_purchase_timestamp, order_id) AS rn
  FROM order_facts
),
first_orders AS (
  SELECT * FROM ranked
  WHERE rn = 1 AND ts < '2018-06-02'
),
flags AS (
  SELECT f.customer_unique_id, f.delay_bucket, f.bucket_order, f.is_late,
         MAX(CASE WHEN r.rn > 1
                   AND julianday(r.ts) > julianday(f.ts)
                   AND julianday(r.ts) - julianday(f.ts) <= 90
                  THEN 1 ELSE 0 END) AS repeated_90d
  FROM first_orders f
  JOIN ranked r ON r.customer_unique_id = f.customer_unique_id
  GROUP BY f.customer_unique_id, f.delay_bucket, f.bucket_order, f.is_late
)
SELECT is_late,
       COUNT(*) AS customers,
       SUM(repeated_90d) AS repeaters,
       ROUND(100.0 * SUM(repeated_90d) / COUNT(*), 2) AS repeat_rate_90d_pct
FROM flags
GROUP BY is_late
ORDER BY is_late;
