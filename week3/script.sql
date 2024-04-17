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

--Wednesday 4/17
SELECT Location FROM Site;
SELECT * FROM Site WHERE Area < 200;
-- string pattern matching
SELECT * FROM Site WHERE Area < 200 AND Location LIKE '%USA'; -- "ILIKE" is case insensitive but "LIKE" is case sensitive
-- expressions
SELECT Site_name, Area*2.47 FROM Site; -- so that area is in acres, not hectares
SELECT Site_name, Area*2.47 AS Area_acres FROM Site; -- rename the area column
-- string concatonation
SELECT Site_name || 'foo' FROM Site;
-- Aggregation
SELECT COUNT(*) FROM Site;
SELECT COUNT(*) AS num_rows FROM Site;
.mode box -- changes output format of tables
.mode duckbox
SELECT COUNT(Scientific_name) FROM Species;
SELECT DISTINCT Relevance FROM Species;
SELECT (COUNT(DISTINCT Relevance)) FROM Species; -- how many unique relevances?
-- MIN, MAX, AVG
SELECT AVG(Area) FROM Site;
-- Grouping
SELECT * FROM Site;
SELECT Location, MAX(Area) 
    FROM Site
    GROUP BY Location;
SELECT Location, COUNT(*) FROM Site GROUP BY Location; -- counts how many rows for each "group" aka location
SELECT Relevance, COUNT(*) FROM Species GROUP BY Relevance;
SELECT Relevance, COUNT(Scientific_name) FROM Species GROUP BY Relevance; -- how many non-null scientific names are there in each group?
-- adding WHERE clause
SELECT Location, MAX(Area) -- first select rows you want to operate on
    FROM Site -- what table
    WHERE Location LIKE '%Canada' --condition that filters
    GROUP BY Location; -- finally within those rows, do some grouping
SELECT Location, MAX(Area) AS Max_area 
    FROM Site 
    WHERE Location LIKE '%Canada'
    GROUP BY Location
    HAVING Max_area > 200; -- a futher restriction after the grouping
-- Relational Algebra
SELECT COUNT(*) FROM Site; -- any query returns a table! table algebra!!
SELECT COUNT(*) FROM (SELECT COUNT(*) FROM Site); -- can confirm, there is one row in the baby table 
SELECT * FROM Bird_nests LIMIT 3;
-- are there any species for which we have no bird nest data?
SELECT * FROM Species
    WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests);
-- saving queries temporarily
CREATE TEMP TABLE t AS -- as soon as we exit out of duckdb, table disappears. if want permenent table remove "TEMP"
    SELECT * FROM Species
    WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests);
SELECT * FROM t;
-- or saving permanently
CREATE TABLE t_perm AS
    SELECT * FROM Species
    WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests);
SELECT * FROM t_perm;
-- delete a table
DROP TABLE t_perm;
-- NULL Processing
SELECT COUNT(*) FROM Bird_nests
    WHERE floatAge > 5;
SELECT COUNT(*) FROM Bird_nests
    WHERE floatAge <= 5;
SELECT COUNT(*) FROM Bird_nests; -- total rows much greater than the number of non-null floatAges
-- SQL has tri-value logic: TRUE FALSE or NULL: is NULL > 5? NULL
SELECT COUNT(*) FROM Bird_nests WHERE floatAge = NULL; -- DOESNT WORK
SELECT COUNT(*) FROM Bird_nests WHERE floatAge IS NULL;

-- JOINS
SELECT * FROM Camp_assignment;
SELECT * FROM Personnel;
SELECT * FROM Camp_assignment JOIN Personnel
    ON Observer = Abbreviation;
-- joins temporarily de-normalizes your data
SELECT * FROM Camp_assignment JOIN Personnel
    ON Camp_assignment.Observer = Personnel.Abbreviation;
SELECT * FROM Camp_assignment AS ca JOIN Personnel AS p
    ON ca.Observer = p.Abbreviation;
-- Multiway Joins
SELECT * FROM Camp_assignment ca JOIN Personnel p
    ON ca.Observer = p.Abbreviation
    JOIN Site s
    ON ca.site = s.Code
    LIMIT 3;
SELECT * FROM Camp_assignment ca JOIN Personnel p
    ON ca.Observer = p.Abbreviation
    JOIN Site s
    ON ca.site = s.Code
    WHERE ca.Observer = 'lmckinnon'
    LIMIT 3;
-- very last step should be order by, otherwise it will get lost
SELECT * FROM Camp_assignment ca JOIN (
    SELECT * FROM Personnel ORDER BY Abbreviation -- this order doesn't stay during the join
) p
    ON ca.Observer = p.Abbreviation
    JOIN Site s
    ON ca.site = s.Code
    WHERE ca.Observer = 'lmckinnon'
    LIMIT 3;

-- More on Grouping
-- How many bird eggs are in each nest?
SELECT Nest_ID, COUNT(Egg_num)
    FROM Bird_eggs
    GROUP BY Nest_ID;