-- ============================================
-- Apache Hive Script: Export Results
-- ============================================
-- This script exports query results for visualization
-- ============================================

USE evaluation_db;

-- Export department statistics
INSERT OVERWRITE LOCAL DIRECTORY '/tmp/hive_output/department_stats'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT 
    department,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    MAX(salary) AS max_salary,
    MIN(salary) AS min_salary,
    SUM(salary) AS total_salary
FROM employee_orc
GROUP BY department
ORDER BY avg_salary DESC;

-- Export city-wise statistics
INSERT OVERWRITE LOCAL DIRECTORY '/tmp/hive_output/city_stats'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT 
    city,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    SUM(salary) AS total_salary
FROM employee_orc
GROUP BY city
ORDER BY employee_count DESC;

-- Export salary distribution
INSERT OVERWRITE LOCAL DIRECTORY '/tmp/hive_output/salary_distribution'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT 
    CASE 
        WHEN salary >= 80000 THEN 'High (>=80k)'
        WHEN salary >= 65000 THEN 'Medium (65k-80k)'
        ELSE 'Low (<65k)'
    END AS salary_range,
    COUNT(*) AS count
FROM employee_orc
GROUP BY 
    CASE 
        WHEN salary >= 80000 THEN 'High (>=80k)'
        WHEN salary >= 65000 THEN 'Medium (65k-80k)'
        ELSE 'Low (<65k)'
    END
ORDER BY 
    CASE 
        WHEN salary_range = 'High (>=80k)' THEN 1
        WHEN salary_range = 'Medium (65k-80k)' THEN 2
        ELSE 3
    END;

-- Export top employees by salary
INSERT OVERWRITE LOCAL DIRECTORY '/tmp/hive_output/top_employees'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT 
    emp_id,
    emp_name,
    department,
    salary,
    city
FROM employee_orc
ORDER BY salary DESC
LIMIT 10;

