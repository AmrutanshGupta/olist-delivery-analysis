-- Question: Order Gap Lag
-- Technique: LAG window function
-- Output columns: prev_bucket, repeat_orders, avg_days_between_orders

WITH seq AS (
  SELECT customer_unique_id, order_id, purchase_date, delay_bucket,
         LAG(purchase_date) OVER (PARTITION BY customer_unique_id
                                  ORDER BY order_purchase_timestamp, order_id) AS prev_date,
         LAG(delay_bucket)  OVER (PARTITION BY customer_unique_id
                                  ORDER BY order_purchase_timestamp, order_id) AS prev_bucket
  FROM order_facts
)
SELECT prev_bucket,
       COUNT(*) AS repeat_orders,
       ROUND(AVG(julianday(purchase_date) - julianday(prev_date)), 1) AS avg_days_between_orders
FROM seq
WHERE prev_date IS NOT NULL
GROUP BY prev_bucket;
