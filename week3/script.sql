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
SELECT Nest_ID, COUNT(*)
    FROM Bird_eggs
    GROUP BY Nest_ID;


-- WEEK 4 Mon 4/22
SELECT Species FROM Bird_nests WHERE Site = 'nome';
SELECT Species, COUNT(*) AS Nest_count
    FROM Bird_nests WHERE Site = 'nome'
    GROUP BY Species
    ORDER BY Species
    LIMIT 2;
-- nesting queries
SELECT Scientific_name, Nest_count FROM
    (SELECT Species, COUNT(*) AS Nest_count
    FROM Bird_nests WHERE Site = 'nome'
    GROUP BY Species
    ORDER BY Species
    LIMIT 2) JOIN Species ON Species = Code;
-- outer joins
CREATE TEMP TABLE a (cola INTEGER, common INTEGER);
INSERT INTO a VALUES (1,1), (2,2), (3,3);
SELECT * FROM a;
CREATE TEMP TABLE b (common INTEGER, colb INTEGER);
INSERT INTO b VALUES (2,2), (3,3), (4,4), (5,5);
SELECT * FROM b;
    --inner join
    SELECT * FROM a  INNER JOIN b USING (common); -- only keeps what they have in common
    -- left or right outer join
    SELECT * FROM a LEFT JOIN b USING (common);
-- change how NULL values are displayed
.nullvalue -NULL-

SELECT * FROM a RIGHT JOIN b USING (common);

-- What species do *not* have any nest data?
SELECT * FROM Species 
    WHERE Code NOT IN (SELECT DISTINCT Species From Bird_nests);
    -- answer using an outer join
    SELECT Code, Scientific_name, Nest_ID, Species, Year 
        FROM Species LEFT JOIN Bird_nests ON Code = Species
        WHERE Nest_ID IS NULL; 

-- A gotcha when doing grouping
SELECT * FROM Bird_eggs LIMIT 3;
SELECT * FROM Bird_nests JOIN Bird_eggs USING (Nest_ID)
    WHERE Nest_ID = '14eabaage01';
SELECT Nest_ID, COUNT(*)
    FROM Bird_nests JOIN Bird_eggs USING (Nest_ID)
    WHERE Nest_ID = '14eabaage01'
    GROUP BY Nest_ID;
-- but what about this?
-- conceptually, adding length does not make sense bc there are 3 unique values
SELECT Nest_ID, COUNT(*), Length
    FROM Bird_nests JOIN Bird_eggs USING (Nest_ID)
    WHERE Nest_ID = '14eabaage01'
    GROUP BY Nest_ID;
-- new query
-- Species only exists in Bird_nests so it's the same in every row after the group by, but duckdb doesn't like this
SELECT Nest_ID, Species, COUNT(*)
    FROM Bird_nests JOIN Bird_eggs USING (Nest_ID)
    WHERE Nest_ID = '14eabaage01'
    GROUP BY Nest_ID;
    -- add group by species
    SELECT Nest_ID, Species, COUNT(*)
        FROM Bird_nests JOIN Bird_eggs USING (Nest_ID)
        WHERE Nest_ID = '14eabaage01'
        GROUP BY Nest_ID, Species;
    -- workaround #2 ANY_VALUE
    SELECT Nest_ID, ANY_VALUE(Species), COUNT(*)
        FROM Bird_nests JOIN Bird_eggs USING (Nest_ID)
        WHERE Nest_ID = '14eabaage01'
        GROUP BY Nest_ID;
-- Views
SELECT * FROM Camp_assignment;
SELECT Year, Site, NAme, Start, "End"
    FROM Camp_assignment JOIN Personnel
    ON Observer = Abbreviation;
CREATE VIEW v AS
    SELECT Year, Site, NAme, Start, "End"
    FROM Camp_assignment JOIN Personnel
    ON Observer = Abbreviation;
-- a view looks just like a table, but it's not real
SELECT * FROM v;

-- set operations: UNION INTERSECT EXCEPT
-- iffy example
SELECT Book_page, Nest_ID, Egg_num, Length, Width FROM Bird_eggs;
-- if there was a problem on one book page:
SELECT Book_page, Nest_ID, Egg_num, Length*25.4, Width*25.4 FROM Bird_eggs
    WHERE Book_page = 'b14.6'
    UNION -- like an rbind
SELECT Book_page, Nest_ID, Egg_num, Length, Width FROM Bird_eggs
    WHERE Book_page != 'b14.6';
-- UNION vs UNION ALL
-- just mashes tables together
-- Third way to answer: Which species had no nest data?
SELECT Code FROM Species
    EXCEPT SELECT DISTINCT Species FROM Bird_nests; -- don't want any species in the bird nest table