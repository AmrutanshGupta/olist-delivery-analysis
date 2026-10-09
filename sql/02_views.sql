DROP VIEW IF EXISTS v_reviews_dedup;
CREATE VIEW v_reviews_dedup AS
SELECT order_id, review_score
FROM (
  SELECT order_id, review_score,
         ROW_NUMBER() OVER (
           PARTITION BY order_id
           ORDER BY review_answer_timestamp DESC, review_id
         ) AS rn
  FROM order_reviews
)
WHERE rn = 1;

DROP VIEW IF EXISTS order_facts;
CREATE VIEW order_facts AS
WITH items AS (
  SELECT order_id,
         COUNT(*)                    AS item_count,
         COUNT(DISTINCT seller_id)   AS seller_count,
         SUM(price)                  AS items_value,
         SUM(freight_value)          AS freight_value
  FROM order_items
  GROUP BY order_id
),
first_item AS (
  SELECT order_id, seller_id, product_id
  FROM order_items
  WHERE order_item_id = 1
),
pay AS (
  SELECT order_id, SUM(payment_value) AS payment_value
  FROM order_payments
  GROUP BY order_id
),
base AS (
  SELECT
    o.order_id,
    c.customer_unique_id,
    c.customer_state,
    c.customer_city,
    o.order_purchase_timestamp,
    date(o.order_purchase_timestamp)             AS purchase_date,
    strftime('%Y-%m', o.order_purchase_timestamp) AS purchase_month,
    date(o.order_delivered_customer_date)        AS delivered_date,
    date(o.order_estimated_delivery_date)        AS estimated_date,
    CAST(julianday(date(o.order_delivered_customer_date))
       - julianday(date(o.order_estimated_delivery_date)) AS INTEGER) AS delay_days,
    CAST(julianday(date(o.order_delivered_customer_date))
       - julianday(date(o.order_purchase_timestamp)) AS INTEGER)      AS actual_days,
    CAST(julianday(date(o.order_estimated_delivery_date))
       - julianday(date(o.order_purchase_timestamp)) AS INTEGER)      AS promised_days
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND date(o.order_delivered_customer_date) >= date(o.order_purchase_timestamp)
    AND date(o.order_purchase_timestamp) BETWEEN '2017-01-01' AND '2018-08-31'
)
SELECT
  b.*,
  CASE WHEN b.delay_days <= 0 THEN 1 ELSE 0 END AS on_time_flag,
  CASE WHEN b.delay_days <= 0 THEN 0 ELSE 1 END AS is_late,
  CASE WHEN b.delay_days <= 0 THEN 'On time'
       WHEN b.delay_days BETWEEN 1 AND 3 THEN '1-3 days late'
       ELSE '4+ days late' END                  AS delay_bucket,
  CASE WHEN b.delay_days <= 0 THEN 1
       WHEN b.delay_days BETWEEN 1 AND 3 THEN 2
       ELSE 3 END                               AS bucket_order,
  i.item_count, i.seller_count, i.items_value, i.freight_value,
  p.payment_value,
  fi.seller_id                                  AS primary_seller_id,
  s.seller_state                                AS primary_seller_state,
  COALESCE(t.product_category_name_english, 'unknown') AS category,
  r.review_score
FROM base b
JOIN items i               ON i.order_id = b.order_id
LEFT JOIN first_item fi    ON fi.order_id = b.order_id
LEFT JOIN products pr      ON pr.product_id = fi.product_id
LEFT JOIN category_translation t ON t.product_category_name = pr.product_category_name
LEFT JOIN sellers s        ON s.seller_id = fi.seller_id
LEFT JOIN pay p            ON p.order_id = b.order_id
LEFT JOIN v_reviews_dedup r ON r.order_id = b.order_id;
