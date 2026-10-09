-- Question: Data Quality Checks
-- Technique: UNION ALL
-- Output columns: check_name, issue_count, handling

SELECT 'Delivered-status orders with a NULL delivered date' AS check_name,
       COUNT(*) AS issue_count,
       'excluded' AS handling
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL
UNION ALL
SELECT 'Orders where delivered date is before purchase date',
       COUNT(*),
       'excluded'
FROM orders
WHERE date(order_delivered_customer_date) < date(order_purchase_timestamp)
UNION ALL
SELECT 'Orders with more than one review',
       COUNT(*),
       'deduplicated'
FROM (
  SELECT order_id
  FROM order_reviews
  GROUP BY order_id
  HAVING COUNT(*) > 1
)
UNION ALL
SELECT 'Orders in orders with no rows in order_items',
       COUNT(*),
       'excluded'
FROM orders o
LEFT JOIN order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL
UNION ALL
SELECT 'Products with a NULL product_category_name',
       COUNT(*),
       'labeled unknown'
FROM products
WHERE product_category_name IS NULL
UNION ALL
SELECT 'Delivered orders with no review',
       COUNT(*),
       'kept with a nullable review'
FROM orders o
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered' AND r.order_id IS NULL
UNION ALL
SELECT 'Orders outside the analysis window',
       COUNT(*),
       'excluded'
FROM orders
WHERE order_status = 'delivered'
  AND (date(order_purchase_timestamp) < '2017-01-01' OR date(order_purchase_timestamp) > '2018-08-31');
