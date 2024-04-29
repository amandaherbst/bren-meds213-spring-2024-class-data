-- WEEK 5 Monday 4/29/24

-- INSERT STATEMENTS
-- inserting data
SELECT* FROM Species;
.maxrows 8
INSERT INTO Species VALUES ('abcd', 'thing', 'scientific name', NULL);
SELECT * FROM Species;

-- you can explicitly label the columns
INSERT INTO Species (Common_name, Scientific_name, Code, Relevance)
    VALUES ('thing 2', 'another scientific name', 'efgh', NULL);
SELECT * FROM Species;
-- columns can have default values, so if you name the columns in an insert, 
-- you don't necessarily have to name all the columns
-- take advantage of default values:
INSERT INTO Species (Common_name, Code) VALUES ('thing 3', 'ik]jkl');
.nullvalue -NULL-
SELECT * FROM Species;
-- naming columns is also important for explicitness and strength of the statement
-- if not naming, then its relying on the columns always being in the same order

-- UPDATE and DELETE
-- very dangerous commands
UPDATE Species SET Relevance = 'not sure yet' 
    WHERE Relevance IS NULL;
SELECT * FROM Species;
-- remove rows where relevance = 'not sure yet'
DELETE FROM Species WHERE Relevance = 'not sure yet';
-- SAFE DELETE practice #1
SELECT * FROM Species WHERE Relevance = 'Study species';
    -- once you confirm these are the rows you want to delete, can edit statement
    -- replace SELECT * with DELETE
-- SAFE DELETE practice #2
FROM Species WHERE ...
    -- incomplete statement, only add DELETE after visual confirmation

-- EXPORTING DATA
-- getting data out of database
-- write a table as a csv file
COPY Species TO 'species_fixed.csv' (HEADER, DELIMITER ',');
    -- can create a query/view and save that as a csv file

-- IMPORTING DATA
-- first, CREATE TABLE statement
CREATE TABLE Snow_cover2 (
    Site VARCHAR NOT NULL,
    Year INTEGER NOT NULL CHECK (Year BETWEEN 1950 AND 2015),
    Date DATE NOT NULL,
    Plot VARCHAR, -- some Null in the data :/
    Location VARCHAR NOT NULL,
    Snow_cover INTEGER CHECK (Snow_cover > -1 AND Snow_cover < 101),
    Observer VARCHAR
);
SELECT * FROM Snow_cover2;
-- then, insert data from csv
COPY Snow_cover2 FROM 'snow_cover_fixedman_JB.csv' (HEADER TRUE);

-- TRIGGERS
-- (Duckdb doesn't support triggers so this is in SQLite)
CREATE TRIGGER Update_species
AFTER INSERT ON Species
FOR EACH ROW
BEGIN
    UPDATE Species 
    SET Scientific_name = NULL 
    WHERE Code = new.Code AND Scientrific_name = '';
    -- end each statement within "BEGIN" with a semicolon
END;