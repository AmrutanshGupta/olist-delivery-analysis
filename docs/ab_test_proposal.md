# A/B Test Proposal: Delay-Compensation Voucher

**Unit:** Customer with a late first order.
**Control:** No voucher.
**Treatment:** Apology voucher sent automatically upon delivery of the late order.

**Primary Metric:** 90-day repeat rate (percentage of customers who place another order within 90 days).
**Secondary Metric:** Review score of the next order.
**Guardrail Metric:** Voucher cost per retained customer (must remain below customer lifetime value).

**Randomization:** Randomization at the customer level.

**Sample Size Estimate:** Computed via the two-proportion formula using the observed base rate for late orders.
