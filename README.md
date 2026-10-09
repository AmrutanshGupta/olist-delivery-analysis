# Why Do Orders Go Wrong? Delivery Delays, Reviews and Repeat Customers

## Problem
In a competitive e-commerce marketplace, late deliveries are a primary driver of customer churn and poor brand reputation. The business question at the core of this project is: **How much do late deliveries cost in customer satisfaction and repeat purchases, and where should operations intervene first?**

## Dataset
This project uses the [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), covering ~100k orders made between 2016 and 2018. The analysis focuses on a fixed window (orders purchased 2017-01-01 to 2018-08-31).

## Why this dataset mirrors a delivery platform
The Olist dataset provides a realistic view of an e-commerce operation containing multiple tables: orders, customers, order items, payments, reviews, products, and sellers. Like any modern delivery platform, it features distributed sellers, diverse product categories, complex logistics (freight), and actual customer feedback scores, making it a perfect testbed for measuring real operational impact.

## Approach
The architecture of this project is designed for robustness and reproducibility:
`CSV → SQLite → SQL views → CSV → Tableau`

1. **Extraction and Loading:** A Python script automatically downloads the raw CSVs from Kaggle and loads them into a local SQLite database, carefully maintaining type fidelity and establishing indexes.
2. **Transformation:** Core SQL views (`order_facts`) are generated to clean, flatten, and join 7 different tables down to a single row per order.
3. **Analysis:** A suite of 12 commented SQL queries answer specific analytical questions, using techniques like CTEs, window functions, and cohort analysis.
4. **Visualization:** The outputs are exported as pre-aggregated CSVs, which are then connected to a Tableau Public dashboard.

## Key Findings
1. **On-Time Rate and Trend:** The system overall has a 93% on-time rate, but is fragile to network-wide shocks.
2. **Review Score Drop by Delay Bucket:** Orders that are 4+ days late average 1.85 stars compared to 4.29 stars for on-time orders (a drop of 2.44 points).
3. **Concentration of Delays in Sellers and States:** Just ~10% of sellers are responsible for ~74% of all late orders, pointing to a highly localized problem.
4. **Repeat-Rate Gap:** A late delivery correlates with a 0.25 percentage point drop in the 90-day repeat rate (from 2.03% to 1.77%).

## Dashboard Link and Screenshots
*(The human analyst will publish the Tableau Dashboard and provide the link here, alongside screenshot images)*
- [Dashboard Link] (TBD)
- `docs/page1.png` (TBD)
- `docs/page2.png` (TBD)
- `docs/page3.png` (TBD)

## SQL Techniques Used
This analysis relies heavily on advanced SQL techniques in SQLite, including:
- `JOIN`s across 4+ tables to create a flattened analytical view.
- `CTE`s (Common Table Expressions) for query readability and staged aggregations.
- `CASE` statements to create delay buckets and flags.
- `RANK` and `ROW_NUMBER` window functions for deduplication and ranking.
- `LAG` window function to calculate the gap between sequential orders.
- `AVG() OVER (ROWS BETWEEN...)` for 3-month rolling averages.
- `SUM() OVER (ORDER BY... ROWS BETWEEN UNBOUNDED PRECEDING...)` for cumulative sums (Pareto analysis).
- Cohort analysis to track 90-day repeat purchase behavior.

## Data Quality Handling
Several data quality issues were proactively handled:
- Orders without a delivered date or where the delivered date preceded the purchase date were excluded.
- Orders with duplicate reviews were deduplicated.
- Products with missing categories were labeled `unknown`.
- Out-of-bounds dates were excluded to prevent sparse data artifacts.
*(Detailed in `docs/data_quality_notes.md`)*

## Limitations
- **Observational Data:** The repeat-rate gap is an association, not a proof of causation. A proposed A/B test (detailed in `docs/ab_test_proposal.md`) is recommended to establish causality.
- **Low Base Repeat Rate:** The dataset natively exhibits a very low 90-day repeat rate (~2%), typical of this specific marketplace snapshot, meaning massive sample sizes are required for strong statistical significance.
- **Tableau Public Snapshot:** The dashboard relies on static CSV extracts.

## How to reproduce
To run the entire data pipeline from end to end (requires Python 3.10+ and Kaggle credentials):
```bash
bash run_all.sh
```

## Resume Bullet
Analyzed 95K+ marketplace delivery orders in SQL (CTEs, window functions, cohort analysis) and built a 3-page Tableau dashboard; found late deliveries lowered review scores by 2.44 points and cut 90-day repeat rate by 0.25 pp; identified 10% of sellers driving 74% of delays.
