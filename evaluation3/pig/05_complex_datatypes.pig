-- ============================================
-- Apache Pig Script: Complex Data Types
-- ============================================
-- This script demonstrates:
-- 1. Tuple (complex structure)
-- 2. Bag (collection of tuples)
-- 3. Map (key-value pairs)
-- ============================================

-- Load sales data
sales_data = LOAD '/user/hadoopuser/sales_data.csv' 
    USING PigStorage(',') 
    AS (order_id:int, customer_id:int, product_name:chararray, quantity:int, price:float, category:chararray, date:chararray);

-- Remove header row
sales_data = FILTER sales_data BY order_id IS NOT NULL AND order_id != 0;

-- ===== TUPLE Example =====
-- Create a tuple with order details
order_tuples = FOREACH sales_data GENERATE 
    order_id AS order_id,
    (customer_id, product_name, quantity, price) AS order_details; -- This is a tuple

-- ===== BAG Example =====
-- GROUP creates a bag (collection of tuples)
grouped_by_customer = GROUP sales_data BY customer_id;

-- Each group contains a bag of sales records
customer_bags = FOREACH grouped_by_customer {
    -- The bag contains all sales records for each customer
    order_list = sales_data.order_id;
    GENERATE 
        group AS customer_id,
        order_list AS order_ids; -- This is a bag
}

-- ===== MAP Example =====
-- Create a map with product attributes
product_maps = FOREACH sales_data GENERATE 
    order_id AS order_id,
    ['product_name'#product_name, 'quantity'#(quantity AS chararray), 'price'#(price AS chararray), 'category'#category] AS product_info; -- This is a map

-- Access map values using key
product_names = FOREACH product_maps GENERATE 
    order_id,
    product_info#'product_name' AS product,
    product_info#'category' AS category;

-- ===== Complex Example: Bag of Tuples =====
-- Group by customer and create bag of order details
customer_order_bags = FOREACH grouped_by_customer GENERATE 
    group AS customer_id,
    {
        FOREACH sales_data GENERATE 
            order_id,
            product_name,
            quantity,
            price,
            (quantity * price) AS revenue;
    } AS orders; -- Bag of tuples

-- Display results
DUMP order_tuples;
DUMP customer_bags;
DUMP product_maps;
DUMP customer_order_bags;

-- Store results
STORE order_tuples INTO '/user/hadoopuser/pig_output/complex_tuples';
STORE customer_bags INTO '/user/hadoopuser/pig_output/complex_bags';
STORE product_maps INTO '/user/hadoopuser/pig_output/complex_maps';
STORE customer_order_bags INTO '/user/hadoopuser/pig_output/complex_bags_tuples';

