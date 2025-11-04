-- ============================================
-- Apache Pig Script: Eval Functions
-- ============================================
-- This script demonstrates:
-- 1. SUM function
-- 2. AVG function
-- 3. COUNT function
-- 4. GROUP BY operation
-- ============================================

-- Load sales data
sales_data = LOAD '/user/hadoopuser/sales_data.csv' 
    USING PigStorage(',') 
    AS (order_id:int, customer_id:int, product_name:chararray, quantity:int, price:float, category:chararray, date:chararray);

-- Remove header row - filter out non-numeric order_ids
sales_data = FILTER sales_data BY order_id IS NOT NULL AND order_id != 0;

-- Calculate total revenue per order (quantity * price)
sales_with_revenue = FOREACH sales_data GENERATE 
    order_id, 
    customer_id, 
    product_name, 
    quantity, 
    price, 
    (quantity * price) AS revenue;

-- GROUP BY customer_id and calculate statistics
grouped_by_customer = GROUP sales_with_revenue BY customer_id;

-- Calculate SUM, AVG, COUNT per customer
customer_stats = FOREACH grouped_by_customer GENERATE 
    group AS customer_id,
    SUM(sales_with_revenue.revenue) AS total_revenue,
    AVG(sales_with_revenue.revenue) AS avg_revenue,
    COUNT(sales_with_revenue) AS order_count,
    SUM(sales_with_revenue.quantity) AS total_quantity;

-- GROUP BY product and calculate statistics
grouped_by_product = GROUP sales_with_revenue BY product_name;

product_stats = FOREACH grouped_by_product GENERATE 
    group AS product_name,
    SUM(sales_with_revenue.revenue) AS total_revenue,
    AVG(sales_with_revenue.price) AS avg_price,
    COUNT(sales_with_revenue) AS order_count,
    SUM(sales_with_revenue.quantity) AS total_quantity_sold;

-- Display results
DUMP customer_stats;
DUMP product_stats;

-- Store results
STORE customer_stats INTO '/user/hadoopuser/pig_output/customer_stats';
STORE product_stats INTO '/user/hadoopuser/pig_output/product_stats';

