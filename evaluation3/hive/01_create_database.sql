-- ============================================
-- Apache Hive Script: Database Creation
-- ============================================
-- This script creates a database for evaluation
-- ============================================

-- Create database
CREATE DATABASE IF NOT EXISTS evaluation_db;

-- Use the database
USE evaluation_db;

-- Show databases
SHOW DATABASES;

-- Show current database
SELECT current_database();

