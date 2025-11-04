-- ============================================
-- Apache Pig Script: JOIN Operation
-- ============================================
-- This script demonstrates:
-- 1. JOIN operation between two datasets
-- 2. Combining sales and customer data
-- ============================================

-- Load sales data
sales_data = LOAD '/user/hadoopuser/sales_data.csv' 
    USING PigStorage(',') 
    AS (order_id:int, customer_id:int, product_name:chararray, quantity:int, price:float, category:chararray, date:chararray);

-- Remove header row
sales_data = FILTER sales_data BY order_id IS NOT NULL AND order_id != 0;

-- Load customer data
customer_data = LOAD '/user/hadoopuser/customer_data.csv' 
    USING PigStorage(',') 
    AS (customer_id:int, customer_name:chararray, age:int, city:chararray, email:chararray);

-- Remove header row
customer_data = FILTER customer_data BY customer_id IS NOT NULL AND customer_id != 0;

-- JOIN sales and customer data on customer_id
joined_data = JOIN sales_data BY customer_id, customer_data BY customer_id;

-- Create enriched dataset with customer information
enriched_sales = FOREACH joined_data GENERATE 
    sales_data::order_id AS order_id,
    sales_data::customer_id AS customer_id,
    customer_data::customer_name AS customer_name,
    customer_data::city AS city,
    sales_data::product_name AS product_name,
    sales_data::quantity AS quantity,
    sales_data::price AS price,
    (sales_data::quantity * sales_data::price) AS revenue;

-- Display joined results
DUMP enriched_sales;

-- Store joined data
STORE enriched_sales INTO '/user/hadoopuser/pig_output/enriched_sales';

