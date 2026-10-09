# Key Insights

1. **On-Time Rate and Trend**
   - **Evidence:** Overall on-time rate is 93.21% out of 96,203 orders (`q01_kpi_overview.csv`). The monthly trend (`q02_monthly_trend.csv`) shows a baseline close to 95%, but occasional severe drops (such as early 2018 where it dropped significantly).
   - **So What:** While the vast majority of orders arrive on time, the system is fragile and subject to network-wide shocks that affect thousands of customers at once.
   - **Action:** Build early-warning alerts for network congestion based on a leading indicator rather than waiting for customer complaints.

2. **Review Score Drop by Delay Bucket**
   - **Evidence:** On-time orders average 4.29 stars. Orders that are 4+ days late plummet to 1.85 stars (`q03_bucket_vs_review.csv`, `q08_review_by_days_late.csv`).
   - **So What:** A 4-day delay costs 2.44 stars in customer satisfaction. This completely erases a brand's premium reputation and heavily skews the seller's overall rating.
   - **Action:** Introduce an automated proactive communication and apology system (or compensation voucher) for orders projected to be 4+ days late.

3. **Concentration of Delays in Sellers and States**
   - **Evidence:** The top ~10% of sellers account for ~74% of all late orders (`q07_seller_pareto.csv`). Additionally, certain states dramatically underperform the network average (`q04_state_performance.csv`, `q11_opportunity_ranking.csv`).
   - **So What:** The delay problem is heavily localized. Fixing a handful of worst-performing sellers or state routes will have a massive outsized impact on the global on-time rate.
   - **Action:** Temporarily suspend or heavily derank the worst 10% of sellers, or enforce stricter SLA requirements on them before they are allowed back on the platform.

4. **Repeat-Rate Gap**
   - **Evidence:** Customers whose first order is on time have a 90-day repeat rate of 2.03%. If their first order is late, the repeat rate falls to 1.77% (`q09_repeat_cohort_binary.csv`). This is a drop of 0.25 percentage points (95% CI: [-0.10, 0.61]) (`stats_summary.json`).
   - **So What:** While the base repeat rate is low (common in marketplace data), a late delivery still correlates with a ~13% relative drop in customer retention. (Note: Observational data, CI crosses zero due to sample size, but directionally consistent with expectations).
   - **Action:** Run a randomized A/B test with a delay-compensation voucher to definitively measure and plug this retention leak.
