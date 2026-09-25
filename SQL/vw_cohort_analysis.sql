CREATE VIEW vw_cohort_analysis AS 
WITH cohort_base AS (
    SELECT customer_id,
		   DATE_TRUNC('month', MIN(order_date) OVER (PARTITION BY customer_id)) AS cohort_month,
		   DATE_TRUNC('month', order_date) AS order_month
		   
	FROM   orders
	WHERE  status = 'completed'
	
),

cohort_activity AS (
    SELECT *,
		   (EXTRACT(YEAR FROM order_month) - EXTRACT(YEAR FROM cohort_month)) * 12 +
		   (EXTRACT(MONTH FROM order_month) - EXTRACT(MONTH FROM cohort_month)) AS month_number
	FROM	cohort_base
),

cohort_counts AS (
	SELECT cohort_month,
		   month_number,
		   COUNT(DISTINCT customer_id) AS active_customers
	FROM   cohort_activity
	GROUP BY cohort_month, month_number
)

SELECT
	cohort_month,
	TO_CHAR(cohort_month, 'Mon YYYY') AS cohort_month_label,
	month_number,
	'M' || month_number AS retention_month,
	active_customers,
	FIRST_VALUE(active_customers) OVER (PARTITION BY cohort_month ORDER BY month_number) AS cohort_size
FROM cohort_counts
ORDER BY cohort_month, month_number;
