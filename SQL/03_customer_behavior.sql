-- RetailPulse : 03_customer_behavior.sql
-- Purpose: 

--COHORT ANALYSIS
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
)

SELECT cohort_month,
	   month_number,
	   COUNT(DISTINCT customer_id) AS active_customer
FROM   cohort_activity
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number;


-- WHO ARE OUR BEST CUSTOMERS AND WHO ARE WE LOSING (RFM ANALYSIS)
WITH rfm_base AS (
	SELECT customer_id,
		   CURRENT_DATE - MAX(order_date) AS recency_days,
		   COUNT(order_id) AS frequency,
		   SUM (amount) AS monetary
	FROM   orders
	WHERE  status = 'completed'   
	GROUP BY customer_id
),

rfm_scores AS (
SELECT *, 
		(6 - NTILE(5) OVER (ORDER BY recency_days ASC)) AS r_score,
		(6 - NTILE(5) OVER (ORDER BY frequency DESC)) AS f_score,
		(6 - NTILE(5) OVER (ORDER BY monetary DESC)) AS m_score
FROM rfm_base

),

rfm_segments AS (
    SELECT *, 
		CONCAT(r_score, f_score, m_score) AS rfm_combined
	FROM rfm_scores
) 

SELECT *,
	   CASE
	   	  WHEN r_score = 5 AND f_score = 5 THEN 'Champion'
	   	  WHEN r_score >= 4 AND f_score >= 4 THEN 'Loyal'
	   	  WHEN r_score >= 3 AND f_score >= 3 THEN 'Potential Loyal'
	   	  WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customer'
	   	  WHEN r_score <= 2 AND f_score >= 4 THEN 'At Risk'
	   	  WHEN r_score <= 2 AND f_score >= 2 THEN 'Needs Attention'
		  ELSE 'Lost'
		END AS segment
FROM	rfm_segments;


--RFM SEGMENT SUMMARY
--show customer count and average spend per segment 
--Used to prioritize which segment deserves attention
WITH rfm_base AS (
	SELECT customer_id,
		   CURRENT_DATE - MAX(order_date) AS recency_days,
		   COUNT(order_id) AS frequency,
		   SUM (amount) AS monetary
	FROM   orders
	WHERE  status = 'completed'   
	GROUP BY customer_id
),

rfm_scores AS (
SELECT *, 
		(6 - NTILE(5) OVER (ORDER BY recency_days ASC)) AS r_score,
		(6 - NTILE(5) OVER (ORDER BY frequency DESC)) AS f_score,
		(6 - NTILE(5) OVER (ORDER BY monetary DESC)) AS m_score
FROM rfm_base

),

rfm_segments AS (
    SELECT *, 
		CONCAT(r_score, f_score, m_score) AS rfm_combined
	FROM rfm_scores
),

rfm_final AS (
SELECT *,
	   CASE
	   	  WHEN r_score = 5 AND f_score = 5 THEN 'Champion'
	   	  WHEN r_score >= 4 AND f_score >= 4 THEN 'Loyal'
	   	  WHEN r_score >= 3 AND f_score >= 3 THEN 'Potential Loyal'
	   	  WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customer'
	   	  WHEN r_score <= 2 AND f_score >= 4 THEN 'At Risk'
	   	  WHEN r_score <= 2 AND f_score >= 2 THEN 'Needs Attention'
		  ELSE 'Lost'
		END AS segment
FROM	rfm_segments
)

SELECT segment,
	   COUNT(customer_id) AS total_customers,
	   AVG(monetary) AS avg_monetary
FROM   rfm_final
GROUP BY segment
ORDER BY avg_monetary DESC;