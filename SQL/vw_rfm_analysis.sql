CREATE VIEW vw_rfm_analysis AS 
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