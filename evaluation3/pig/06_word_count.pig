-- ============================================
-- Apache Pig Script: Word Count Example
-- ============================================
-- This script demonstrates:
-- 1. Classic Word Count implementation in Pig
-- 2. Text processing operations
-- 3. Tokenization and counting
-- ============================================

-- Load text data from local file (in same directory)
text_data = LOAD 'word_count_input.txt' AS (line:chararray);

-- Split each line into words (tokenize)
-- The TOKENIZE function splits a string into words
words = FOREACH text_data GENERATE FLATTEN(TOKENIZE(line)) AS word;

-- Convert all words to lowercase for proper counting
words_lower = FOREACH words GENERATE LOWER(word) AS word;

-- Filter out empty words (if any)
words_filtered = FILTER words_lower BY word != '';

-- GROUP BY word to collect all occurrences
grouped_words = GROUP words_filtered BY word;

-- COUNT occurrences of each word
word_count = FOREACH grouped_words GENERATE 
    group AS word,
    COUNT(words_filtered) AS count;

-- ORDER BY count (descending) to see most frequent words first
word_count_sorted = ORDER word_count BY count DESC;

-- Display results
DUMP word_count_sorted;

-- Store results
STORE word_count_sorted INTO '/user/hadoopuser/pig_output/word_count';

