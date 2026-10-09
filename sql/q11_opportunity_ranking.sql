-- Question: Opportunity Ranking
-- Technique: CTE, cross join
-- Output columns: level, entity, orders, late_orders, avg_score_points_recoverable
-- Note: recoverable = how much the network-wide average review score would rise if this entity's late orders had scored like on-time orders. This is an estimate, not a causal claim.

WITH gap AS (
  SELECT AVG(CASE WHEN is_late = 0 THEN review_score END)
       - AVG(CASE WHEN is_late = 1 THEN review_score END) AS score_gap,
         COUNT(*) AS total_orders
  FROM order_facts
)
SELECT 'state' AS level, customer_state AS entity,
       COUNT(*) AS orders, SUM(is_late) AS late_orders,
       ROUND(SUM(is_late) * g.score_gap / g.total_orders, 4) AS avg_score_points_recoverable
FROM order_facts, gap g
GROUP BY customer_state
UNION ALL
SELECT 'seller', primary_seller_id, COUNT(*), SUM(is_late),
       ROUND(SUM(is_late) * g.score_gap / g.total_orders, 4)
FROM order_facts, gap g
WHERE primary_seller_id IS NOT NULL
GROUP BY primary_seller_id
ORDER BY level, avg_score_points_recoverable DESC;
