-- ============================================
-- Apache Pig Script: Load and Filter Operations
-- ============================================
-- This script demonstrates:
-- 1. Loading data from HDFS
-- 2. FILTER operation
-- 3. Basic data transformations
-- ============================================

-- Load sales data from HDFS
sales_data = LOAD '/user/hadoopuser/sales_data.csv' 
    USING PigStorage(',') 
    AS (order_id:int, customer_id:int, product_name:chararray, quantity:int, price:float, category:chararray, date:chararray);

-- Remove header row (if exists) - convert to int first
sales_data = FILTER sales_data BY order_id IS NOT NULL AND order_id != 0;

-- Filter: Get orders with quantity greater than 2
high_quantity_orders = FILTER sales_data BY quantity > 2;

-- Filter: Get orders with price greater than 20000
high_value_orders = FILTER sales_data BY price > 20000;

-- Filter: Get Electronics category orders only
electronics_orders = FILTER sales_data BY category == 'Electronics';

-- Display results
DUMP high_quantity_orders;
DUMP high_value_orders;
DUMP electronics_orders;

-- Store filtered results
STORE high_quantity_orders INTO '/user/hadoopuser/pig_output/high_quantity';
STORE high_value_orders INTO '/user/hadoopuser/pig_output/high_value';
STORE electronics_orders INTO '/user/hadoopuser/pig_output/electronics';

