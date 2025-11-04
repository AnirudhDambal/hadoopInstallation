-- ============================================
-- Apache Hive Script: HQL Queries
-- ============================================
-- This script demonstrates:
-- 1. SELECT queries
-- 2. JOIN operations
-- 3. GROUP BY aggregations
-- 4. PARTITION operations
-- ============================================

USE evaluation_db;

-- ===== SELECT Queries =====

-- Basic SELECT
SELECT emp_id, emp_name, department, salary 
FROM employee_orc 
LIMIT 10;

-- SELECT with WHERE clause
SELECT emp_name, department, salary 
FROM employee_orc 
WHERE salary > 70000;

-- SELECT with ORDER BY
SELECT emp_name, department, salary 
FROM employee_orc 
ORDER BY salary DESC 
LIMIT 5;

-- ===== JOIN Queries =====

-- INNER JOIN between employee and department
SELECT 
    e.emp_id,
    e.emp_name,
    e.department,
    e.salary,
    d.department_name,
    d.location,
    d.budget
FROM employee_orc e
INNER JOIN department_orc d 
ON e.department = d.department_name;

-- LEFT JOIN
SELECT 
    e.emp_name,
    e.department,
    e.salary,
    d.location,
    d.budget
FROM employee_orc e
LEFT JOIN department_orc d 
ON e.department = d.department_name;

-- ===== GROUP BY Queries =====

-- GROUP BY department - count employees
SELECT 
    department,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    MAX(salary) AS max_salary,
    MIN(salary) AS min_salary,
    SUM(salary) AS total_salary
FROM employee_orc
GROUP BY department;

-- GROUP BY city
SELECT 
    city,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary
FROM employee_orc
GROUP BY city
ORDER BY employee_count DESC;

-- GROUP BY department and city
SELECT 
    department,
    city,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary
FROM employee_orc
GROUP BY department, city;

-- ===== PARTITION Queries =====
-- Note: For partitioned tables, we need to create a partitioned table first

-- Create partitioned table by department
CREATE TABLE IF NOT EXISTS employee_partitioned (
    emp_id INT,
    emp_name STRING,
    salary INT,
    join_date STRING,
    age INT,
    city STRING
)
PARTITIONED BY (department STRING)
STORED AS ORC;

-- Enable dynamic partitioning
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

-- Insert data into partitioned table
INSERT OVERWRITE TABLE employee_partitioned PARTITION(department)
SELECT emp_id, emp_name, salary, join_date, age, city, department
FROM employee_orc;

-- Query partitioned table - select specific partition
SELECT * FROM employee_partitioned WHERE department = 'IT';

-- Query partitioned table - show all partitions
SHOW PARTITIONS employee_partitioned;

-- Query with partition pruning
SELECT 
    department,
    COUNT(*) AS count,
    AVG(salary) AS avg_salary
FROM employee_partitioned
WHERE department IN ('IT', 'Sales')
GROUP BY department;

