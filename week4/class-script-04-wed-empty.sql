-- opening DuckDB with no database file , aka "in-memory"
> duckdb

-- opening an existing database with DuckDB
> duckdb database_filename.db

-- But Beware!! if you provide a filename that does not exist, DuckDB will create a new empty database with that name
> duckdb database_filename_with_tyop.db

-- Always good to check you have the right database using `.tables` after opening the database


-- Ask 1: What is the average snow cover at each site?
SELECT Site, AVG(Snow_cover)
    FROM Snow_cover
    GROUP BY Site;

-- Ask 2: Order the result to get the top 3 snowy sites?
SELECT Site, AVG(Snow_cover) as avg_snow_cover
    FROM Snow_cover
    GROUP BY Site
    ORDER BY -avg_snow_cover --or instead of "-" add DESC
    LIMIT 3;

-- Ask 3: Save your results into a temporary table named  Site_avg_snowcover
CREATE TEMP TABLE Site_avg_snowcover AS
    SELECT Site, AVG(Snow_cover) as avg_snow_cover
    FROM Snow_cover
    GROUP BY Site
    ORDER BY -avg_snow_cover --or instead of "-" add DESC
    LIMIT 3;

-- Ask 4: How do I check the view was created?
> .tables
> SELECT * FROM Site_avg_snowcover

-- Ask 5: Looking at the data, we have now a doubt about the meaning of the zero values... 
-- what if most of them where supposed to be NULL?! Does it matters? write a query that would check that?
SELECT Site, AVG(Snow_cover) AS avg_snow_cover
    FROM Snow_cover
    WHERE Snow_cover > 0
    GROUP BY Site;

-- Ask 6: Save your results into a **view** named  Site_avg_snowcover_nozeros
CREATE VIEW Site_avg_snowcover_nozeros AS
    SELECT Site, AVG(Snow_cover) AS avg_snow_cover_nozero
    FROM Snow_cover
    WHERE Snow_cover > 0
    GROUP BY Site;

-- Ask 7: Compute the difference between those two ways of computing average
SELECT Site, avg_snow_cover - avg_snow_cover_nozero AS difference FROM
    Site_avg_snowcover 
    JOIN Site_avg_snowcover_nozeros USING (Site);

-- Ask 8: Which site would be the most impacted if zeros were not real zeros? Of Course we need a table for that :)
SELECT Site, avg_snow_cover - avg_snow_cover_nozero AS difference FROM
    Site_avg_snowcover 
    JOIN Site_avg_snowcover_nozeros USING (Site)
    ORDER BY difference
    LIMIT 1;

-- Ask 9: So? Would it be time well spent to further look into the meaning of zeros?
YES

-- We found out that actually at the location `sno05` of the site eaba, 0 means NULL... let's update our Snow_cover table

CREATE TABLE Snow_cover_backup AS SELECT * FROM Snow_cover; -- Create a copy of the table to be safe (and not cry a lot)

-- For Recall
SELECT * FROM Site_avg_snowcover;
SELECT * FROM Site_avg_snowcover_nozeros;
-- update the 0 for that site
UPDATE Snow_cover SET Snow_cover = NULL WHERE Location = 'sno05' AND Snow_cover = 0; 
-- be careful with update, because you can't really undo-this is changing the actual table!!

-- Check the update was succesful
SELECT * FROM Snow_cover WHERE Location = 'sno05';
-- We should probably recompute the avg, let's check
SELECT * FROM Site_avg_snowcover;
-- What just happened!?
-- didn't update bc it is saved as a temporary table, not a view
-- we would need to recompute the table to see any changes
CREATE VIEW Site_avg_snowcover_update AS
    SELECT Site, AVG(Snow_cover) as avg_snow_cover
    FROM Snow_cover
    GROUP BY Site
    ORDER BY -avg_snow_cover
    LIMIT 3;
SELECT * FROM Site_avg_snowcover_update;

-- Average snow cover by site and by year
SELECT Site, Year, AVG(Snow_cover)
    FROM Snow_cover
    GROUP BY Site, Year;

-- Ask 10: Let's move on to inspecting the nests and answering the following question: Which shorebird species makes the most eggs? Oh and I need a table with the common names, just because :)
