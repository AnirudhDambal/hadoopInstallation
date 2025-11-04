# Apache Pig Installation and Execution Guide

Complete guide for installing and running Apache Pig 0.17.0 in WSL environment.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Verification](#verification)
5. [Running Pig Scripts](#running-pig-scripts)
6. [Troubleshooting](#troubleshooting)

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

**If Hadoop is not working:**
- Ensure you're logged in as `hadoopuser`
- Check that `$HADOOP_HOME` is set: `echo $HADOOP_HOME`
- If not set, add to `~/.bashrc`:
  ```bash
  export HADOOP_HOME=/home/hadoopuser/hadoop
  export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
  source ~/.bashrc
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

### Step 2: Download Apache Pig 0.17.0

**Option A: Using wget (Recommended)**

```bash
wget https://downloads.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz
```

**Option B: Using curl**

```bash
curl -O https://downloads.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz
```

**Expected output:**
- File size: ~150 MB
- File name: `pig-0.17.0.tar.gz`

**If download fails:**
- Check internet connection
- Try alternative mirror: `https://archive.apache.org/dist/pig/pig-0.17.0/pig-0.17.0.tar.gz`

### Step 3: Verify Download

```bash
ls -lh pig-0.17.0.tar.gz
```

You should see the file with size around 150 MB.

### Step 4: Extract the Tarball

```bash
tar -xzf pig-0.17.0.tar.gz
```

This will create a directory `pig-0.17.0` in your home directory.

### Step 5: Verify Extraction

```bash
ls -ld ~/pig-0.17.0
ls ~/pig-0.17.0/bin/pig
```

You should see the Pig binary at `~/pig-0.17.0/bin/pig`.

---

## Configuration

### Step 1: Set Environment Variables (Temporary)

```bash
export PIG_HOME=~/pig-0.17.0
export PATH=$PATH:$PIG_HOME/bin
```

### Step 2: Make it Permanent (Add to ~/.bashrc)

```bash
echo "" >> ~/.bashrc
echo "# Apache Pig Configuration" >> ~/.bashrc
echo "export PIG_HOME=~/pig-0.17.0" >> ~/.bashrc
echo "export PATH=\$PATH:\$PIG_HOME/bin" >> ~/.bashrc
```

### Step 3: Reload Environment

```bash
source ~/.bashrc
```

**Verify the variables are set:**
```bash
echo $PIG_HOME
echo $PATH | grep pig
```

You should see:
```
/home/hadoopuser/pig-0.17.0
```

---

## Verification

### Step 1: Check Pig Version

```bash
pig -version
```

**Expected output:**
```
Apache Pig version 0.17.0
...
```

**If you get "command not found":**
- Verify `$PIG_HOME` is set: `echo $PIG_HOME`
- Check PATH: `echo $PATH | grep pig`
- Try: `$PIG_HOME/bin/pig -version`
- Reload: `source ~/.bashrc`

### Step 2: Ensure Hadoop Services Are Running

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
sleep 15  # Wait for NameNode to fully start
start-yarn.sh
sleep 5
```

### Step 3: Test HDFS Connection

```bash
hdfs dfsadmin -report
```

Should show cluster information, not "Connection refused".

---

## Running Pig Scripts

### Prerequisites

Before running Pig scripts, ensure:

1. **Hadoop services are running:**
   ```bash
   jps
   ```

2. **Datasets are uploaded to HDFS** (for scripts 1-5):
   ```bash
   cd /mnt/c/Users/aniru/OneDrive/Desktop/BDA/hadoopInstallation
   hdfs dfs -mkdir -p /user/hadoopuser
   hdfs dfs -mkdir -p /user/hadoopuser/pig_output
   hdfs dfs -put evaluation3/datasets/sales_data.csv /user/hadoopuser/
   hdfs dfs -put evaluation3/datasets/customer_data.csv /user/hadoopuser/
   ```

3. **Word count input file** (for script 6):
   - The `word_count_input.txt` file is in the same directory as the script
   - No HDFS upload needed for this script

### Scripts Overview

1. **01_load_and_filter.pig** - Demonstrates loading data and FILTER operations
2. **02_eval_functions.pig** - Shows SUM, AVG, COUNT functions with GROUP BY
3. **03_join_operation.pig** - Demonstrates JOIN between two datasets
4. **04_group_order.pig** - Shows GROUP BY and ORDER BY operations
5. **05_complex_datatypes.pig** - Demonstrates tuple, bag, and map data types
6. **06_word_count.pig** - Classic Word Count implementation (uses local file)

### Running Scripts

Navigate to the pig directory:

```bash
cd /mnt/c/Users/aniru/OneDrive/Desktop/BDA/hadoopInstallation/evaluation3/pig
```

#### Method 1: Command Line Mode (Recommended)

Run each script individually:

```bash
pig 01_load_and_filter.pig
pig 02_eval_functions.pig
pig 03_join_operation.pig
pig 04_group_order.pig
pig 05_complex_datatypes.pig
pig 06_word_count.pig
```

#### Method 2: Grunt Shell (Interactive Mode)

```bash
pig
```

Then in the Grunt shell:
```pig
exec 01_load_and_filter.pig
exec 02_eval_functions.pig
-- Continue with other scripts
```

### Execution Order

1. **First**, run `01_load_and_filter.pig` to understand basic operations
2. **Then**, run `02_eval_functions.pig` for aggregation functions
3. **Next**, run `03_join_operation.pig` for JOIN operations
4. **Continue** with `04_group_order.pig` for GROUP and ORDER
5. **Run** `05_complex_datatypes.pig` for complex data types
6. **Finally**, run `06_word_count.pig` for Word Count example

### Viewing Results

#### View output files in HDFS

```bash
# List all output directories
hdfs dfs -ls /user/hadoopuser/pig_output/

# View specific results
hdfs dfs -cat /user/hadoopuser/pig_output/word_count/part-r-00000
hdfs dfs -cat /user/hadoopuser/pig_output/customer_stats/part-r-00000
hdfs dfs -cat /user/hadoopuser/pig_output/top_customers/part-r-00000
```

#### Download results to local filesystem

```bash
hdfs dfs -get /user/hadoopuser/pig_output/word_count ./local_output/
```

---

## Key Concepts Demonstrated

### Relational Operators
- **FILTER**: Filter rows based on conditions
- **JOIN**: Combine data from multiple sources
- **GROUP**: Group data by key
- **ORDER**: Sort data

### Eval Functions
- **SUM**: Sum of numeric values
- **AVG**: Average of numeric values
- **COUNT**: Count of records

### Complex Data Types
- **Tuple**: Ordered collection of fields `(field1, field2, ...)`
- **Bag**: Collection of tuples `{(tuple1), (tuple2), ...}`
- **Map**: Key-value pairs `['key1'#value1, 'key2'#value2]`

### Word Count Steps
1. Load text data
2. Tokenize (split into words)
3. Convert to lowercase
4. Group by word
5. Count occurrences
6. Sort by count

---

## Troubleshooting

### Issue 1: "pig: command not found"

**Solution:**
```bash
# Check if PIG_HOME is set
echo $PIG_HOME

# If empty, set it
export PIG_HOME=~/pig-0.17.0
export PATH=$PATH:$PIG_HOME/bin

# Reload
source ~/.bashrc

# Verify
which pig
```

### Issue 2: "Cannot connect to HDFS"

**Solution:**
```bash
# Check Hadoop services
jps

# If NameNode is missing, start Hadoop
start-dfs.sh
sleep 15  # Important: wait for NameNode
start-yarn.sh

# Test HDFS
hdfs dfsadmin -report

# Verify HDFS is accessible
hdfs dfs -ls /
```

### Issue 3: "Connection refused" error

**Solution:**
- Wait longer after `start-dfs.sh` (15-20 seconds)
- Check NameNode logs: `tail -50 $HADOOP_HOME/logs/hadoop-*-namenode-*.log`
- If NameNode directory doesn't exist, format it (first time only):
  ```bash
  hdfs namenode -format -force -nonInteractive
  ```

### Issue 4: "Permission denied" errors

**Solution:**
```bash
# Check file permissions
ls -l ~/pig-0.17.0/bin/pig

# Make executable if needed
chmod +x ~/pig-0.17.0/bin/pig

# Check directory permissions
ls -ld ~/pig-0.17.0
```

### Issue 5: "Java not found" errors

**Solution:**
```bash
# Check Java
java -version

# Set JAVA_HOME if needed
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Add to ~/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> ~/.bashrc
source ~/.bashrc
```

### Issue 6: "File not found" in Pig scripts

**Solution:**
- For scripts 1-5: Ensure datasets are uploaded to HDFS
  ```bash
  hdfs dfs -ls /user/hadoopuser/
  ```
- For script 6: Ensure `word_count_input.txt` is in the same directory as the script
- Check file paths in Pig scripts match actual locations

### Issue 7: Pig script execution fails

**Solution:**
- Check Pig logs: `tail -f /tmp/pig.log` or check log files in script directory
- Verify HDFS is accessible: `hdfs dfsadmin -report`
- Check Hadoop services: `jps`
- Review error messages in Pig output

---

## Quick Reference

### Essential Commands

```bash
# Check Pig installation
pig -version

# Check Pig home directory
echo $PIG_HOME

# Run a Pig script
pig script.pig

# Run Pig interactively
pig
# Then type Pig Latin commands

# Check Hadoop services
jps

# Check HDFS status
hdfs dfsadmin -report

# View HDFS files
hdfs dfs -ls /user/hadoopuser/
```

### File Locations

- **Pig Installation:** `~/pig-0.17.0`
- **Pig Binary:** `~/pig-0.17.0/bin/pig`
- **Configuration:** `~/.bashrc` (environment variables)
- **Scripts:** `evaluation3/pig/`
- **Word Count Input:** `evaluation3/pig/word_count_input.txt`

### Execution Modes

**MapReduce Mode (Default):**
- Uses Hadoop cluster
- Jobs run on YARN
- Data from/to HDFS
- Better for large datasets
- Run: `pig script.pig`

**Local Mode:**
- Runs on single machine
- No Hadoop/YARN needed
- Faster for small datasets
- Good for testing
- Run: `pig -x local script.pig` (requires local file paths)

---

## Verification Checklist

Before considering setup complete, verify:

- [ ] `pig -version` command works
- [ ] `$PIG_HOME` is set correctly
- [ ] Pig is in `$PATH`
- [ ] Environment variables are in `~/.bashrc`
- [ ] Hadoop services are running (NameNode, DataNode, etc.)
- [ ] HDFS is accessible (`hdfs dfsadmin -report`)
- [ ] Datasets are uploaded to HDFS (for scripts 1-5)
- [ ] Word count input file exists (for script 6)
- [ ] Simple Pig script runs successfully

---

## Support

If you encounter issues not covered in this guide:

1. Check Pig logs: `ls ~/pig-0.17.0/logs/` or log files in script directory
2. Check Hadoop logs: `ls $HADOOP_HOME/logs/`
3. Verify environment: `env | grep -i pig`
4. Review Pig documentation: https://pig.apache.org/docs/latest/

---

**Installation and Execution Complete!** You can now use Apache Pig for your Big Data evaluation.

