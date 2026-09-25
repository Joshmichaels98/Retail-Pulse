CREATE TABLE customers (
customer_id VARCHAR(10),
customer_name VARCHAR(50),
email VARCHAR(50),
country VARCHAR(50),
city VARCHAR(50),
sign_up DATE
)

CREATE TABLE events (
customer_id VARCHAR(10),
event_type VARCHAR(50),
event_date DATE
)

CREATE TABLE order_items (
order_items_id INT,
order_id VARCHAR(10),
product_id VARCHAR(10),
quantity INT,
unit_price NUMERIC(10, 2)
)
CREATE TABLE orders (
order_id VARCHAR(10),
customer_id VARCHAR(10),
order_date DATE,
status VARCHAR(50),
amount NUMERIC(10, 2)
)

CREATE TABLE products (
product_id VARCHAR(10),
product_name VARCHAR(50),
category VARCHAR(50),
price NUMERIC(10, 2)
)

CREATE TABLE regions (
country VARCHAR(50),
region VARCHAR(50),
market VARCHAR(50)
)










