# Tableau Dashboard Build Specification

**Tools:** Tableau Public Desktop (free).

**Data Sources:**
1. Connect to `orders.csv` first.
2. Add the other CSVs (`monthly.csv`, `states.csv`, `sellers_top.csv`, `cohort.csv`, `opportunity.csv`) as separate data sources.

## Calculated Fields (on the `orders` source)
- `On-Time %`: `SUM([on_time_flag]) / COUNT([order_id])`
- `Late Orders`: `SUM([is_late])`
- `Avg Review`: `AVG([review_score])`
- `Late Rate %`: `SUM([is_late]) / COUNT([order_id])`

## Global Rules
- **Page Size:** 1200×800 fixed.
- **Colors:**
  - Late/bad = red `#C0392B`
  - Good/on-time = a single blue `#2E86C1`
  - Everything else = grey `#7F8C8D` or `#BDC3C7`
- **Charts:** No pie charts. Every chart title states its insight, using real numbers from the outputs.

## Page 1: Executive Overview
- **4 KPI Cards:** Total Orders, On-Time %, Avg Review, 90-day Repeat Rate (from `cohort.csv`, binary overall).
- **Line Chart:** `purchase_month` vs `On-Time %`, with the 3-month average from `monthly.csv` as a second line.
- **Filters:** purchase date range, customer state.

## Page 2: Delay Diagnosis
- **Bar Chart:** `delay_bucket` (sorted by `bucket_order`) vs `Avg Review`. Colors: blue, grey, red. Title example: "Orders 4+ days late score X stars lower than on-time orders."
- **Filled Map:** `states.csv`, state name geographic role "State/Province", country Brazil, colored by `late_rate_pct`. If the map fails to geocode, use a sorted horizontal bar chart.
- **Horizontal Bar:** top 15 categories by late rate.
- **Pareto Line:** `cum_pct_of_late_orders` vs `cum_pct_of_sellers`. Title: "X% of sellers cause Y% of late orders."

## Page 3: Customer Impact and Action
- **Bar Chart:** 90-day repeat rate by `delay_bucket` from `cohort.csv` (`cohort_type = '3-bucket'`).
- **Table:** top 10 states and top 10 sellers by `avg_score_points_recoverable` from `opportunity.csv`.
- **Text Box:** 3 recommended actions (from `docs/insights.md`).

**Publish:** File → Save to Tableau Public.
