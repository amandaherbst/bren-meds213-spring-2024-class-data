--ASSIGNMENT 3

--PROBLEM 1

--Part 1
-- create table
CREATE TEMP TABLE mytable (
    mycolumn REAL);
-- populate table, including a NULL value
INSERT INTO mytable VALUES (1),(2),(1),(1),(NULL);
--calculate average of the 
SELECT AVG(mycolumn) FROM mytable;
-- if ignored NULLs, avg = 1.25 (5/4)
-- if counts NULLs, avg = 1 (5/5)
-- answer is 1.25

--Part 2
SELECT SUM(mycolumn)/COUNT(*) FROM mytable;
SELECT SUM(mycolumn)/COUNT(mycolumn) FROM mytable; --this one is correct

--PROBLEM 2
--Part 1
SELECT Site_name, MAX(Area) FROM Site;
--Binder Error: column "Site_name" must appear in the GROUP BY clause or must be part of an aggregate function.
--Either add it to the GROUP BY list, or use "ANY_VALUE(Site_name)" if the exact value of "Site_name" is not important.
-- the problem is that we are trying to do a group by, we want to calculate the maz area for each site

--Part 2
--Time for plan B. Find the site name and area of the site having the largest area.
--Do so by ordering the rows in a particularly convenient order, and using LIMIT to select just the first row. 
SELECT Site_name, Area FROM Site ORDER BY -Area LIMIT 1;


--Part 3
--Do the same, but use a nested query. First, create a query that finds the maximum area. 
--Then, create a query that selects the site name and area of the site whose area equals the maximum. 
--Your overall query will look something like: SELECT Site_name, Area FROM Site WHERE Area = (SELECT ...);

-- query that finds max area
SELECT MAX(Area) From Site;

-- overall query
SELECT Site_name, Area FROM Site WHERE Area = (
    SELECT MAX(Area) From Site
);

-- PROBLEM 3
--Your mission is to list the scientific names of bird species in descending order 
-- of their maximum average egg volumes. That is, compute the average volume of the eggs in each nest, 
-- and then for the nests of each species compute the maximum of those average volumes, 
-- and list by species in descending order of maximum volume.

-- with intermediate tables
CREATE TEMP TABLE Averages AS
    SELECT Nest_ID, AVG((3.14/6)*(Width^2)*Length) AS Avg_volume
        FROM Bird_eggs 
        GROUP BY Nest_ID;
-- join with nest table to get associated species code
CREATE TEMP TABLE Species_avgs AS
    SELECT Species, MAX(Avg_volume) AS Max_vol
        FROM Bird_nests JOIN Averages USING (Nest_ID)
        Group BY Species;
-- join with species table to get scientific name
SELECT Scientific_name, Max_vol
    FROM Species s JOIN Species_avgs sa ON s.Code = sa.Species
    ORDER BY -Max_vol;

-- in one statement...
SELECT Scientific_name, Max_vol
    FROM Bird_eggs be JOIN Bird_nests bn USING Nest_ID
    JOIN Species s ON bn.Species = s.Code
    WHERE Max_vol = (
        SELECT Species, MAX(Avg_vol) 
        WHERE Avg_vol = (
            SELECT Nest_ID, AVG((3.14/6)*(Width^2)*Length) AS Avg_vol 
            FROM Bird_eggs
        )
    );