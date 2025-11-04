# Apache Hive Installation and Execution Guide

Complete guide for installing and running Apache Hive in WSL environment for Big Data evaluation.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Metastore Initialization](#metastore-initialization)
5. [Verification](#verification)
6. [Running Hive Scripts](#running-hive-scripts)
7. [UDF Implementation](#udf-implementation)
8. [Exporting Results](#exporting-results)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### 1. Check Java Installation

```bash
java -version
```

You should see output like:
```
openjdk version "11.0.28"
```

**If Java is not installed:**
```bash
sudo apt update
sudo apt install openjdk-11-jdk
```

### 2. Verify Hadoop is Working

```bash
hadoop version
```

You should see:
```
Hadoop 3.3.6
```

**Ensure Hadoop services are running:**
```bash
jps
```

You should see:
- NameNode
- DataNode
- SecondaryNameNode
- ResourceManager
- NodeManager

**If services are not running:**
```bash
start-dfs.sh
sleep 15
start-yarn.sh
```

### 3. Check Available Disk Space

```bash
df -h ~
```

Ensure you have at least **500 MB** free space.

---

## Installation

### Step 1: Navigate to Home Directory

```bash
cd ~
pwd
```

You should be in `/home/hadoopuser`.

### Step 2: Download Apache Hive

**Option A: Using wget (Recommended)**

```bash
wget https://downloads.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
```

**Option B: Using curl**

```bash
curl -O https://downloads.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
```

**Expected output:**
- File size: ~250 MB
- File name: `apache-hive-3.1.3-bin.tar.gz`

**Alternative versions:**
- Hive 3.1.2: `https://downloads.apache.org/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz`
- Hive 2.3.9: `https://downloads.apache.org/hive/hive-2.3.9/apache-hive-2.3.9-bin.tar.gz`

### Step 3: Verify Download

```bash
ls -lh apache-hive-3.1.3-bin.tar.gz
```

You should see the file with size around 250 MB.

### Step 4: Extract the Tarball

```bash
tar -xzf apache-hive-3.1.3-bin.tar.gz
```

This will create a directory `apache-hive-3.1.3-bin` in your home directory.

### Step 5: Rename for Convenience (Optional)

```bash
mv apache-hive-3.1.3-bin hive
```

### Step 6: Verify Extraction

```bash
ls -ld ~/hive
ls ~/hive/bin/hive
```

You should see the Hive binary at `~/hive/bin/hive`.

---

## Configuration

### Step 1: Set Environment Variables (Temporary)

```bash
export HIVE_HOME=~/hive
export PATH=$PATH:$HIVE_HOME/bin
```

### Step 2: Make it Permanent (Add to ~/.bashrc)

```bash
echo "" >> ~/.bashrc
echo "# Apache Hive Configuration" >> ~/.bashrc
echo "export HIVE_HOME=~/hive" >> ~/.bashrc
echo "export PATH=\$PATH:\$HIVE_HOME/bin" >> ~/.bashrc
```

### Step 3: Set HADOOP_HOME (if not already set)

```bash
# Check if HADOOP_HOME is set
echo $HADOOP_HOME

# If not set, add to ~/.bashrc
echo "export HADOOP_HOME=/home/hadoopuser/hadoop" >> ~/.bashrc
echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> ~/.bashrc
```

### Step 4: Reload Environment

```bash
source ~/.bashrc
```

**Verify the variables are set:**
```bash
echo $HIVE_HOME
echo $HADOOP_HOME
echo $PATH | grep hive
```

You should see:
```
/home/hadoopuser/hive
/home/hadoopuser/hadoop
```

### Step 5: Configure Hive

#### Create Hive Configuration Directory

```bash
mkdir -p $HIVE_HOME/conf
```

#### Create hive-site.xml (if needed)

For basic setup, Hive can work with default configuration. However, you may want to create `hive-site.xml`:

```bash
cat > $HIVE_HOME/conf/hive-site.xml << 'EOF'
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:derby:;databaseName=metastore_db;create=true</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>org.apache.derby.jdbc.EmbeddedDriver</value>
  </property>
  <property>
    <name>hive.metastore.local</name>
    <value>true</value>
  </property>
  <property>
    <name>hive.metastore.warehouse.dir</name>
    <value>/user/hadoopuser/hive/warehouse</value>
  </property>
</configuration>
EOF
```

---

## Metastore Initialization

### Step 1: Create HDFS Directory for Hive Warehouse

```bash
hdfs dfs -mkdir -p /user/hadoopuser/hive/warehouse
hdfs dfs -chmod g+w /user/hadoopuser/hive/warehouse
```

### Step 2: Initialize Hive Metastore (First Time Only)

```bash
schematool -dbType derby -initSchema
```

**Expected output:**
```
Metastore connection URL: jdbc:derby:;databaseName=metastore_db;create=true
Metastore Connection Driver : org.apache.derby.jdbc.EmbeddedDriver
Metastore connection User: APP
Starting metastore schema initialization to 3.1.0
Initialization script hive-schema-3.1.0.derby.sql
Initialization script completed
schemaTool completed
```

**Important:** This command should only be run once. If you run it again, you may need to remove the existing metastore_db directory first.

### Step 3: Verify Metastore Initialization

```bash
ls -la metastore_db/
```

You should see the metastore database files.

---

## Verification

### Step 1: Check Hive Version

```bash
hive --version
```

**Expected output:**
```
Hive 3.1.3
...
```

**If you get "command not found":**
- Verify `$HIVE_HOME` is set: `echo $HIVE_HOME`
- Check PATH: `echo $PATH | grep hive`
- Try: `$HIVE_HOME/bin/hive --version`
- Reload: `source ~/.bashrc`

### Step 2: Test Hive Connection

```bash
hive -e "SHOW DATABASES;"
```

**Expected output:**
```
OK
default
Time taken: X seconds, Fetched: 1 row(s)
```

### Step 3: Test HDFS Access

```bash
hdfs dfs -ls /user/hadoopuser/hive/warehouse
```

Should show the warehouse directory.

---

## Running Hive Scripts

### Prerequisites

Before running Hive scripts, ensure:

1. **Hadoop services are running:**
   ```bash
   jps
   ```

2. **Hive metastore is initialized:**
   ```bash
   ls -la metastore_db/
   ```

3. **Datasets are available:**
   ```bash
   # Upload datasets to HDFS
   cd /mnt/c/Users/aniru/OneDrive/Desktop/BDA/hadoopInstallation
   hdfs dfs -mkdir -p /user/hadoopuser
   hdfs dfs -put evaluation3/datasets/employee_data.csv /user/hadoopuser/
   hdfs dfs -put evaluation3/datasets/department_data.csv /user/hadoopuser/
   ```

### Scripts Overview

1. **01_create_database.sql** - Creates the evaluation database
2. **02_create_tables_textfile.sql** - Creates tables with TextFile format
3. **03_create_tables_orc.sql** - Creates tables with ORC format
4. **04_create_tables_rcfile.sql** - Creates tables with RCFile format
5. **05_hql_queries.sql** - Demonstrates SELECT, JOIN, GROUP BY, PARTITION queries
6. **06_udf_implementation.java** - Custom UDF implementation (Java source)
7. **07_udf_usage.sql** - Demonstrates UDF usage
8. **08_export_results.sql** - Exports results for visualization

### Running Scripts

Navigate to the hive directory:

```bash
cd /mnt/c/Users/aniru/OneDrive/Desktop/BDA/hadoopInstallation/evaluation3/hive
```

#### Method 1: Command Line Mode (Recommended)

Run each script individually:

```bash
# Create database
hive -f 01_create_database.sql

# Create TextFile tables
hive -f 02_create_tables_textfile.sql

# Create ORC tables
hive -f 03_create_tables_orc.sql

# Create RCFile tables
hive -f 04_create_tables_rcfile.sql

# Run HQL queries
hive -f 05_hql_queries.sql

# UDF usage (after compiling UDF)
hive -f 07_udf_usage.sql

# Export results
hive -f 08_export_results.sql
```

#### Method 2: Interactive Hive Shell

```bash
hive
```

Then in the Hive shell:
```sql
-- Run commands directly
CREATE DATABASE IF NOT EXISTS evaluation_db;
USE evaluation_db;

-- Or source SQL files
SOURCE 01_create_database.sql;
SOURCE 02_create_tables_textfile.sql;
```

### Execution Order

1. **First**, run `01_create_database.sql` to create the database
2. **Then**, run `02_create_tables_textfile.sql` to create TextFile tables
3. **Next**, run `03_create_tables_orc.sql` to create ORC tables
4. **Continue** with `04_create_tables_rcfile.sql` for RCFile tables
5. **Run** `05_hql_queries.sql` for various HQL queries
6. **For UDF**: Compile and use (see UDF section below)
7. **Run** `07_udf_usage.sql` for UDF demonstration
8. **Finally**, run `08_export_results.sql` to export data for visualization

### Viewing Results

#### View query results in Hive shell

```bash
hive
```

```sql
USE evaluation_db;
SELECT * FROM employee_orc LIMIT 10;
```

#### View exported files

```bash
# View exported results
cat /tmp/hive_output/department_stats/000000_0
cat /tmp/hive_output/city_stats/000000_0
cat /tmp/hive_output/salary_distribution/000000_0
```

#### View tables in HDFS

```bash
hdfs dfs -ls /user/hadoopuser/hive/warehouse/evaluation_db.db/
```

---

## UDF Implementation

### Step 1: Compile UDF

Create a directory for compilation:

```bash
cd /mnt/c/Users/aniru/OneDrive/Desktop/BDA/hadoopInstallation/evaluation3/hive
mkdir -p udf_build
cd udf_build
```

Copy the UDF source file:

```bash
cp ../06_udf_implementation.java .
```

Compile the UDF:

```bash
# Set classpath (adjust paths as needed)
export HADOOP_CLASSPATH=$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HIVE_HOME/lib/*

# Compile
javac -cp $HADOOP_CLASSPATH:$HIVE_HOME/lib/* EmployeeFormatterUDF.java

# Create JAR
jar cf EmployeeFormatterUDF.jar EmployeeFormatterUDF.class
```

### Step 2: Use UDF in Hive

```bash
hive
```

```sql
-- Add JAR
ADD JAR /mnt/c/Users/aniru/OneDrive/Desktop/BDA/hadoopInstallation/evaluation3/hive/udf_build/EmployeeFormatterUDF.jar;

-- Create temporary function
CREATE TEMPORARY FUNCTION format_employee AS 'EmployeeFormatterUDF';

-- Use the function
SELECT format_employee(emp_name) AS formatted_name, department, salary
FROM employee_orc
LIMIT 10;
```

### Step 3: Alternative - Using Built-in Functions

If UDF compilation is complex, you can use built-in Hive functions for demonstration:

```sql
-- Similar functionality using built-in functions
SELECT 
    CONCAT('EMP: ', UPPER(emp_name)) AS formatted_name,
    department,
    salary
FROM employee_orc
LIMIT 10;
```

---

## Exporting Results

### Step 1: Run Export Script

```bash
cd /mnt/c/Users/aniru/OneDrive/Desktop/BDA/hadoopInstallation/evaluation3/hive
hive -f 08_export_results.sql
```

### Step 2: Create Output Directories (if needed)

```bash
mkdir -p /tmp/hive_output/department_stats
mkdir -p /tmp/hive_output/city_stats
mkdir -p /tmp/hive_output/salary_distribution
mkdir -p /tmp/hive_output/top_employees
```

### Step 3: View Exported Data

```bash
# View department statistics
cat /tmp/hive_output/department_stats/000000_0

# View city statistics
cat /tmp/hive_output/city_stats/000000_0

# View salary distribution
cat /tmp/hive_output/salary_distribution/000000_0
```

### Step 4: Use for Visualization

The exported data can be used with Python visualization scripts:

```bash
cd /mnt/c/Users/aniru/OneDrive/Desktop/BDA/hadoopInstallation/evaluation3/visualizations
python3 create_visualizations.py
```

---

## Key Concepts Demonstrated

### Database Operations
- CREATE DATABASE
- USE DATABASE
- SHOW DATABASES

### Table Operations
- CREATE TABLE with different storage formats
- LOAD DATA
- INSERT OVERWRITE
- DESCRIBE FORMATTED

### Storage Formats

**TextFile:**
- Default format in Hive
- Human-readable, uncompressed
- Good for small datasets

**ORC (Optimized Row Columnar):**
- Columnar storage format
- Better compression than TextFile
- Improved query performance
- Recommended for analytical workloads

**RCFile (Record Columnar File):**
- Hybrid row-columnar format
- Good compression
- Better for analytical queries than TextFile

### HQL Queries
- SELECT with WHERE, ORDER BY
- JOIN (INNER, LEFT)
- GROUP BY with aggregations
- PARTITION operations

### UDF (User Defined Function)
- Custom function implementation
- Function registration
- Function usage in queries

---

## Troubleshooting

### Issue 1: "hive: command not found"

**Solution:**
```bash
# Check if HIVE_HOME is set
echo $HIVE_HOME

# If empty, set it
export HIVE_HOME=~/hive
export PATH=$PATH:$HIVE_HOME/bin

# Reload
source ~/.bashrc

# Verify
which hive
```

### Issue 2: "Metastore errors" or "Schema initialization failed"

**Solution:**
```bash
# Check if metastore_db exists
ls -la metastore_db/

# If corrupted, remove and reinitialize (WARNING: This deletes all Hive metadata)
rm -rf metastore_db
schematool -dbType derby -initSchema
```

### Issue 3: "Cannot connect to HDFS"

**Solution:**
```bash
# Check Hadoop services
jps

# If NameNode is missing, start Hadoop
start-dfs.sh
sleep 15
start-yarn.sh

# Test HDFS
hdfs dfsadmin -report

# Verify HDFS is accessible
hdfs dfs -ls /
```

### Issue 4: "Table not found" errors

**Solution:**
- Ensure you're in the correct database: `USE evaluation_db;`
- Check if tables exist: `SHOW TABLES;`
- Verify tables were created: `DESCRIBE employee_orc;`
- Check if data was loaded: `SELECT COUNT(*) FROM employee_orc;`

### Issue 5: "Permission denied" errors

**Solution:**
```bash
# Check HDFS permissions
hdfs dfs -ls /user/hadoopuser/hive/

# Fix permissions if needed
hdfs dfs -chmod -R 755 /user/hadoopuser/hive/

# Check file permissions
ls -l $HIVE_HOME/bin/hive
chmod +x $HIVE_HOME/bin/hive
```

### Issue 6: "Java compilation errors" (UDF)

**Solution:**
```bash
# Verify Java is installed
java -version

# Check classpath
echo $HADOOP_CLASSPATH

# Ensure all required JARs are in classpath
export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$HIVE_HOME/lib/*
```

### Issue 7: "Export directory not found"

**Solution:**
```bash
# Create output directories
mkdir -p /tmp/hive_output/department_stats
mkdir -p /tmp/hive_output/city_stats
mkdir -p /tmp/hive_output/salary_distribution
mkdir -p /tmp/hive_output/top_employees

# Check permissions
ls -ld /tmp/hive_output/
```

### Issue 8: "Connection timeout" or "Metastore connection failed"

**Solution:**
- Check if metastore is initialized: `ls -la metastore_db/`
- Verify Hive configuration: `cat $HIVE_HOME/conf/hive-site.xml`
- Check Hive logs: `ls $HIVE_HOME/logs/`
- Try restarting: exit Hive and start again

---

## Quick Reference

### Essential Commands

```bash
# Check Hive installation
hive --version

# Check Hive home directory
echo $HIVE_HOME

# Start Hive shell
hive

# Run Hive script
hive -f script.sql

# Initialize metastore (first time only)
schematool -dbType derby -initSchema

# Check HDFS status
hdfs dfsadmin -report

# View Hive warehouse
hdfs dfs -ls /user/hadoopuser/hive/warehouse/
```

### File Locations

- **Hive Installation:** `~/hive` or `~/apache-hive-3.1.3-bin`
- **Hive Binary:** `~/hive/bin/hive`
- **Metastore Database:** `~/metastore_db/`
- **Configuration:** `~/.bashrc` (environment variables)
- **Hive Warehouse:** `/user/hadoopuser/hive/warehouse/` (in HDFS)
- **Scripts:** `evaluation3/hive/`

### Common Hive Commands

```sql
-- Show databases
SHOW DATABASES;

-- Use database
USE evaluation_db;

-- Show tables
SHOW TABLES;

-- Describe table
DESCRIBE employee_orc;

-- View table structure
DESCRIBE FORMATTED employee_orc;

-- Query data
SELECT * FROM employee_orc LIMIT 10;

-- Exit Hive
EXIT;
```

---

## Verification Checklist

Before considering setup complete, verify:

- [ ] `hive --version` command works
- [ ] `$HIVE_HOME` is set correctly
- [ ] Hive is in `$PATH`
- [ ] Environment variables are in `~/.bashrc`
- [ ] Hadoop services are running
- [ ] HDFS is accessible
- [ ] Metastore is initialized
- [ ] Database and tables are created
- [ ] Data is loaded into tables
- [ ] Queries execute successfully
- [ ] Results can be exported

---

## Support

If you encounter issues not covered in this guide:

1. Check Hive logs: `ls $HIVE_HOME/logs/`
2. Check Hadoop logs: `ls $HADOOP_HOME/logs/`
3. Check metastore: `ls -la metastore_db/`
4. Verify environment: `env | grep -i hive`
5. Review Hive documentation: https://hive.apache.org/

---

**Installation and Execution Complete!** You can now use Apache Hive for your Big Data evaluation.

