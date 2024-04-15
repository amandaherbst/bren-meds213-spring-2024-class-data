-- Monday transcript
SELECT * FROM Species; -- selectin ALL columns from species table
.tables -- see all tables in our database

-- SQL is not case-senstive
select * from species;

--limiting rows 
SELECT * FROM Species LIMIT 5;
SELECT * FROM Species LIMIT 5 OFFSET 5;
-- How many rows?
SELECT COUNT(*) FROM Species;
-- If put column name in Count(), how many non-NULL values?
SELECT COUNT(Scientific_name) FROM Species;
-- Can select which columns to return by naming them
SELECT Code, Common_name FROM Species;
-- How many distinct values occur? (like unique() in R)
SELECT DISTINCT Species FROM Bird_nests;
-- get distinct combinations
SELECT DISTINCT Species, Observer FROM Bird_nests;
-- ordering of results
SELECT DISTINCT Species FROM Bird_nests ORDER BY Species; --alphabetical order
--Exercise: what distinct locations occur in Site table? Order them 
--Also limit to 3 results
SELECT DISTINCT Location FROM Site ORDER BY Location LIMIT 3;