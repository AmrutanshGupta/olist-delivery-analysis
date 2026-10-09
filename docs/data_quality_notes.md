# Data Quality Notes

During the extraction and loading process, we ran several data quality checks (q12_data_quality). Here is how we handled each issue in the core view (`order_facts`):

1. **Delivered-status orders with a NULL delivered date**: excluded
2. **Orders where delivered date is before purchase date**: excluded
3. **Orders with more than one review**: deduplicated (kept only the latest review by answer timestamp)
4. **Orders in orders with no rows in order_items**: excluded (filtered implicitly by our items CTE)
5. **Products with a NULL product_category_name**: labeled `unknown`
6. **Delivered orders with no review**: kept with a nullable review
7. **Orders outside the analysis window**: excluded (restricted to 2017-01-01 to 2018-08-31)
