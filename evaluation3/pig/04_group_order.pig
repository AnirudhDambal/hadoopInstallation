-- ============================================
-- Apache Pig Script: GROUP and ORDER Operations
-- ============================================
-- This script demonstrates:
-- 1. GROUP BY operation
-- 2. ORDER BY operation (sorting)
-- 3. Combining GROUP and ORDER
-- ============================================

-- Load sales data
sales_data = LOAD '/user/hadoopuser/sales_data.csv' 
    USING PigStorage(',') 
    AS (order_id:int, customer_id:int, product_name:chararray, quantity:int, price:float, category:chararray, date:chararray);

-- Remove header row
sales_data = FILTER sales_data BY order_id IS NOT NULL AND order_id != 0;

-- Calculate revenue
sales_with_revenue = FOREACH sales_data GENERATE 
    order_id, 
    customer_id, 
    product_name, 
    quantity, 
    price, 
    (quantity * price) AS revenue;

-- GROUP BY customer_id
grouped_by_customer = GROUP sales_with_revenue BY customer_id;

-- Aggregate statistics per customer
customer_summary = FOREACH grouped_by_customer GENERATE 
    group AS customer_id,
    SUM(sales_with_revenue.revenue) AS total_revenue,
    COUNT(sales_with_revenue) AS order_count,
    AVG(sales_with_revenue.revenue) AS avg_order_value;

-- ORDER BY total_revenue (descending)
top_customers = ORDER customer_summary BY total_revenue DESC;

-- GROUP BY product_name
grouped_by_product = GROUP sales_with_revenue BY product_name;

-- Aggregate statistics per product
product_summary = FOREACH grouped_by_product GENERATE 
    group AS product_name,
    SUM(sales_with_revenue.revenue) AS total_revenue,
    SUM(sales_with_revenue.quantity) AS total_quantity,
    AVG(sales_with_revenue.price) AS avg_price;

-- ORDER BY total_revenue (descending)
top_products = ORDER product_summary BY total_revenue DESC;

-- Display results
DUMP top_customers;
DUMP top_products;

-- Store results
STORE top_customers INTO '/user/hadoopuser/pig_output/top_customers';
STORE top_products INTO '/user/hadoopuser/pig_output/top_products';

