-- RetailPulse : 02_sales_performance.sql
-- Purpose: Revenue trends, growth and momentum

--MONTHLY REVENUE TREND
--Tracks revenue performance month by month to identify peaks and slow downs
SELECT DATE_TRUNC('month', order_date) AS month,
	   SUM(amount) AS revenue
FROM   orders
WHERE  status = 'completed'
GROUP BY 1
ORDER BY 1;



--MONTH OVER MONTH (MoM) REVENUE GROWTH %
-- Measures momentum by comparing each month to the previous month
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date) AS month,
	   SUM(amount) AS revenue
    FROM   orders
    WHERE  status = 'completed'
    GROUP BY 1
),
prev_mth AS (
    SELECT *, 
	   LAG(revenue) OVER(ORDER BY month) AS prev_mth_rev
    FROM 	monthly_revenue
)

SELECT *, ROUND(
			(revenue - prev_mth_rev)/ prev_mth_rev * 100, 2
) AS mom_growth
FROM  prev_mth
ORDER BY month;



--YEAR OVER YEAR (YoY) REVENUE GROWTH %
--Compares same month across years to strip out seasonality
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date) AS month,
	   SUM(amount) AS revenue
    FROM   orders
    WHERE  status = 'completed'
    GROUP BY 1
),
prev_year AS (
    SELECT *, 
	   LAG(revenue, 12) OVER(ORDER BY month) AS prev_year_rev
    FROM 	monthly_revenue
)

SELECT *, ROUND(
			(revenue - prev_year_rev)/ prev_year_rev * 100, 2
) AS yoy_growth
FROM  prev_year
ORDER BY month;



--REVENUE RUNNING TOTAL
--Tracks cumulative revenue progress within each year and across all time
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date) AS month,
	   SUM(amount) AS revenue
    FROM   orders
    WHERE  status = 'completed'
    GROUP BY 1
)

SELECT *, 
	   SUM(revenue) OVER(PARTITION BY DATE_TRUNC('year', month) ORDER BY month) AS running_total_yearly,
	   SUM(revenue) OVER(ORDER BY month) AS alltime_running_total
FROM monthly_revenue
ORDER BY month;
