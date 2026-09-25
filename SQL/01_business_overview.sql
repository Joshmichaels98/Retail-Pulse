-- RetailPulse : 01_business_overview.sql
-- Purpose: High level business health metrics

--TOTAL REVENUE FROM  ALL COMPLETED ORDERS
SELECT SUM(amount) AS total_revenue
FROM orders
WHERE status = 'completed';

--TOTAL NUMBER OF ORDERS PLACED
SELECT COUNT(order_id) AS total_orders
FROM orders;

--TOTAL UNIQUE REGISTERED CUSTOMERS
SELECT COUNT(DISTINCT customer_id)
FROM customers;

-- TOTAL ACTIVE CUSTOMERS (CUSTOMERS WHO HAVE COMPLETED ATLEAST ONE ORDER)
SELECT COUNT(DISTINCT customer_id) AS active_customers
FROM orders
WHERE status = 'completed'

--AVERAGE ORDER VALUE (AOV)
SELECT ROUND(AVG(amount), 2) AS avG_order_value
FROM orders
WHERE status ='completed';

--REVENUE GENERATED PER COUNTRY
SELECT c.country,
		SUM(o.amount) AS total_revenue
FROM orders o
JOIN customers c
ON 	 o.customer_id = c.customer_id
WHERE o.status = 'completed'
GROUP BY country
ORDER BY total_revenue DESC;

--TOP 5 CUSTOMERS BY TOTAL SPENDINGS
SELECT c.customer_id, 
		c.customer_name,
		SUM(o.amount) AS total_spendings
FROM 	customers c
JOIN 	orders o
ON 		c.customer_id = o.customer_id
WHERE	o.status = 'completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spendings DESC
LIMIT 	5;


		
		
		