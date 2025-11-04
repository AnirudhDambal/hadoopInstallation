-- ============================================
-- Apache Hive Script: Create Tables with TextFile Format
-- ============================================
-- This script creates tables using TextFile format
-- ============================================

USE evaluation_db;

-- Create employee table with TextFile format (default)
CREATE TABLE IF NOT EXISTS employee_textfile (
    emp_id INT,
    emp_name STRING,
    department STRING,
    salary INT,
    join_date STRING,
    age INT,
    city STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hadoopuser/hive/warehouse/evaluation_db.db/employee_textfile';

-- Create department table with TextFile format
CREATE TABLE IF NOT EXISTS department_textfile (
    dept_id STRING,
    department_name STRING,
    location STRING,
    budget BIGINT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hadoopuser/hive/warehouse/evaluation_db.db/department_textfile';

-- Load data into TextFile tables
LOAD DATA LOCAL INPATH '../datasets/employee_data.csv' 
OVERWRITE INTO TABLE employee_textfile;

LOAD DATA LOCAL INPATH '../datasets/department_data.csv' 
OVERWRITE INTO TABLE department_textfile;

-- Verify data loaded
SELECT * FROM employee_textfile LIMIT 5;
SELECT * FROM department_textfile;

