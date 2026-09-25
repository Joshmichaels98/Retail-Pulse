-- RetailPulse : 04_product_intelligence.sql
-- Purpose: product and category performance analysis.

--TOP SELLING PRODUCTS BY QUANTITY SOLD
SELECT p.product_id,
	   p.product_name,
	   SUM(oi.quantity) AS total_quantity_sold
FROM   products p
JOIN   order_items oi
ON	   p.product_id = oi.product_id
JOIN   orders o
ON     oi.order_id = o. order_id
WHERE  o.status = 'completed'
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC;

--TOP PRODUCTS BY REVENUE
SELECT p.product_id,
	   p.product_name,
	   SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM   products p
JOIN   order_items oi
ON	   p.product_id = oi.product_id
JOIN   orders o
ON	   oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

--TOP CATEGORIES BY REVENUE 
SELECT p.category,
	   SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM   products p
JOIN   order_items oi
ON	   p.product_id = oi.product_id
JOIN   orders o
ON	   oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.category
ORDER BY total_revenue DESC;

--MOST POPULAR PRODUCT IN EACH CATEGORY
WITH popular_product AS (
	SELECT p.product_id,
		   p.product_name,
		   p.category,
		   SUM(oi.quantity) AS total_quantity_sold,
		   ROW_NUMBER () OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity) DESC) AS row_number
	FROM   products p
	JOIN   order_items oi
	ON	   p.product_id = oi.product_id
	JOIN   orders o
	ON	   oi.order_id = o.order_id
	WHERE o.status = 'completed'
	GROUP BY p.product_id, p.product_name, p.category
)
SELECT *
FROM popular_product
WHERE row_number = 1
ORDER BY total_quantity_sold DESC;


--TOP UNDERPERFORMING PRODUCTS BY REVENUE
SELECT p.product_id,
	   p.product_name,
	   p.category,
	   SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM   products p
JOIN   order_items oi
ON	   p.product_id = oi.product_id
JOIN   orders o
ON	   oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue ASC;
