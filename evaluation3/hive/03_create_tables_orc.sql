-- ============================================
-- Apache Hive Script: Create Tables with ORC Format
-- ============================================
-- This script creates tables using ORC (Optimized Row Columnar) format
-- ORC is columnar storage format that provides better compression and query performance
-- ============================================

USE evaluation_db;

-- Create employee table with ORC format
CREATE TABLE IF NOT EXISTS employee_orc (
    emp_id INT,
    emp_name STRING,
    department STRING,
    salary INT,
    join_date STRING,
    age INT,
    city STRING
)
STORED AS ORC
LOCATION '/user/hadoopuser/hive/warehouse/evaluation_db.db/employee_orc';

-- Create department table with ORC format
CREATE TABLE IF NOT EXISTS department_orc (
    dept_id STRING,
    department_name STRING,
    location STRING,
    budget BIGINT
)
STORED AS ORC
LOCATION '/user/hadoopuser/hive/warehouse/evaluation_db.db/department_orc';

-- Insert data from TextFile tables to ORC tables
INSERT OVERWRITE TABLE employee_orc
SELECT * FROM employee_textfile;

INSERT OVERWRITE TABLE department_orc
SELECT * FROM department_textfile;

-- Verify data
SELECT * FROM employee_orc LIMIT 5;
SELECT * FROM department_orc;

-- Show table properties
DESCRIBE FORMATTED employee_orc;

