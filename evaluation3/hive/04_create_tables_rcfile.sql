-- ============================================
-- Apache Hive Script: Create Tables with RCFile Format
-- ============================================
-- This script creates tables using RCFile (Record Columnar File) format
-- RCFile is a columnar storage format that provides good compression
-- ============================================

USE evaluation_db;

-- Create employee table with RCFile format
CREATE TABLE IF NOT EXISTS employee_rcfile (
    emp_id INT,
    emp_name STRING,
    department STRING,
    salary INT,
    join_date STRING,
    age INT,
    city STRING
)
STORED AS RCFILE
LOCATION '/user/hadoopuser/hive/warehouse/evaluation_db.db/employee_rcfile';

-- Create department table with RCFile format
CREATE TABLE IF NOT EXISTS department_rcfile (
    dept_id STRING,
    department_name STRING,
    location STRING,
    budget BIGINT
)
STORED AS RCFILE
LOCATION '/user/hadoopuser/hive/warehouse/evaluation_db.db/department_rcfile';

-- Insert data from TextFile tables to RCFile tables
INSERT OVERWRITE TABLE employee_rcfile
SELECT * FROM employee_textfile;

INSERT OVERWRITE TABLE department_rcfile
SELECT * FROM department_textfile;

-- Verify data
SELECT * FROM employee_rcfile LIMIT 5;
SELECT * FROM department_rcfile;

-- Show table properties
DESCRIBE FORMATTED employee_rcfile;

