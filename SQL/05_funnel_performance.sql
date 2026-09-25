-- RetailPulse : 05_funnel_performance.sql
-- Purpose: 

WITH funnel_events AS (
	SELECT customer_id,
	   MIN(CASE WHEN event_type = 'visited_site' THEN event_date END)
	     OVER (PARTITION BY customer_id) AS visited_date,
	   MIN(CASE WHEN event_type = 'viewed_product' THEN event_date END)
	     OVER (PARTITION BY customer_id) AS viewed_date,
	   MIN(CASE WHEN event_type = 'added_to_cart' THEN event_date END)
	     OVER (PARTITION BY customer_id) AS cart_date,
	   MIN(CASE WHEN event_type = 'purchased' THEN event_date END)
	     OVER (PARTITION BY customer_id) AS purchased_date

	FROM events
),

customer_funnel AS (
	SELECT DISTINCT customer_id,
		   			visited_date,
					viewed_date,
					cart_date,
					purchased_date
	FROM 	funnel_events
),

funnel_count AS (
	SELECT
		COUNT(customer_id)AS visited_site,
		COUNT(CASE WHEN viewed_date >= visited_date
					THEN customer_id END) AS viewed_product,
		COUNT(CASE WHEN cart_date >= viewed_date
					THEN customer_id END) AS added_to_cart,
		COUNT(CASE WHEN purchased_date >= cart_date
					THEN customer_id END) AS purchased
	
	FROM customer_funnel
)

SELECT *,
	   ROUND(viewed_product::NUMERIC / visited_site * 100, 2) AS visit_to_view_pct,
	   ROUND(added_to_cart::NUMERIC/ viewed_product * 100, 2) AS view_to_cart_pct,
	   ROUND(purchased::NUMERIC/ added_to_cart * 100, 2) AS cart_to_purchase_pct
FROM   funnel_count;

	


