-- ============================================
-- Apache Hive Script: Using Custom UDF
-- ============================================
-- This script demonstrates how to use the custom UDF
-- ============================================

USE evaluation_db;

-- Step 1: Add JAR file containing UDF
-- (Assuming UDF is compiled and packaged as EmployeeFormatterUDF.jar)
-- ADD JAR /path/to/EmployeeFormatterUDF.jar;

-- Step 2: Create temporary function
-- CREATE TEMPORARY FUNCTION format_employee AS 'EmployeeFormatterUDF';

-- Step 3: Use the UDF in queries
-- SELECT 
--     emp_id,
--     format_employee(emp_name) AS formatted_name,
--     department,
--     salary
-- FROM employee_orc
-- LIMIT 10;

-- Alternative: Using built-in Hive functions for demonstration
-- Since UDF compilation requires Java setup, we'll demonstrate with built-in functions

-- Example 1: Using UPPER function (similar to what UDF does)
SELECT 
    emp_id,
    CONCAT('EMP: ', UPPER(emp_name)) AS formatted_name,
    department,
    salary
FROM employee_orc
LIMIT 10;

-- Example 2: Custom formatting with multiple functions
SELECT 
    emp_id,
    CONCAT('Employee: ', UPPER(SUBSTRING(emp_name, 1, 1)), LOWER(SUBSTRING(emp_name, 2))) AS formatted_name,
    department,
    CONCAT('$', salary) AS formatted_salary
FROM employee_orc
LIMIT 10;

-- Example 3: Using CASE for conditional formatting
SELECT 
    emp_id,
    emp_name,
    department,
    salary,
    CASE 
        WHEN salary > 80000 THEN 'HIGH'
        WHEN salary > 65000 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS salary_grade
FROM employee_orc;

