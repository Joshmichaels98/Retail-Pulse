CREATE VIEW vw_top_product_per_category AS
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