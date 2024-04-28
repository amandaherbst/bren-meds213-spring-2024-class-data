--PROBLEM 1 MISSING DATA
--Which sites have no egg data? Please answer this question using all three techniques demonstrated in class. 
-- In doing so, you will need to work with the Bird_eggs table, the Site table, or both.

-- Using NOT IN
SELECT Code FROM Site
    WHERE Code NOT IN
    (SELECT DISTINCT Site FROM Bird_eggs)
    ORDER BY Code;

-- Outer Join
SELECT Code FROM
    Site s LEFT JOIN Bird_eggs b
    ON b.Site = s.Code
    WHERE Egg_num IS NULL
    ORDER BY Code;

-- EXCEPT
SELECT Code FROM Site
    EXCEPT SELECT DISTINCT Site FROM Bird_eggs
    ORDER BY Code;

-- PROBLEM 2 WHO WORKED WITH WHOM?
-- 
SELECT A.Site, A.Observer AS Observer_1, B.Observer AS Observer_2 
    FROM Camp_assignment A JOIN Camp_assignment B
    ON A.Site = B.Site
    WHERE A.Start <= B.End 
        AND A.End >= B.Start 
        AND A.Site = 'lkri'
        AND A.Observer < B.Observer;

-- PROBLEM 3 WHO'S THE CULPRIT
-- nome site, between 1998 and 2008, age determined by floating
-- 36 nests

        SELECT * FROM 
        -- nested query so I can filter to 36 nests at the end
        (SELECT Name, COUNT(*) AS Num_floated_nests 
        -- join to get full name of the observer
        FROM Bird_nests b JOIN Personnel p
        ON b.Observer = p.Abbreviation
        -- filter to specific site, time, and age method
        WHERE Site = 'nome' 
        AND Year >= 1998 
        AND Year <= 2008
        AND ageMethod = 'float'
        GROUP BY Name)
        -- find the culprit who observed 36 nests exactly
        WHERE Num_floated_nests = 36;