-- CREATE THE DATABASE olympics_db
CREATE DATABASE olympics_db;
USE olympics_db;

-- IMPORT THE DATA
SELECT * FROM athlete_events;
SELECT * FROM athletes;

-- PRIMARY KEY AND SECONDARY KEY
ALTER TABLE athletes
ALTER COLUMN id INT NOT NULL;

ALTER TABLE athletes
ADD PRIMARY KEY (id);

ALTER TABLE athlete_events
ALTER COLUMN athlete_id INT NOT NULL

ALTER TABLE athlete_events
ADD CONSTRAINT fk_athlete_id
FOREIGN KEY (athlete_id)
REFERENCES athletes(id);

-- SOLVING THE QUESTIONS

--1 which team has won the maximum gold medals over the years.
SELECT TOP 1 
A.team, COUNT(E.medal) AS TOTAL_MEDALS 
FROM athletes AS A
INNER JOIN athlete_events AS E
ON A.id = E.athlete_id
WHERE E.medal = 'Gold' 
GROUP BY A.team
ORDER BY TOTAL_MEDALS  DESC;

--2 for each team print total silver medals and year in which they won maximum silver medal..
--output 3 columns team,total_silver_medals, year_of_max_silver
SELECT
A.team,
COUNT(E.medal) AS TOTAL_MEDALS,
YEAR(MAX(E.medal)) AS Year_of_max_silver
FROM athletes A
INNER JOIN athlete_events E
ON A.id = E.athlete_id
WHERE E.medal = 'silver'
GROUP BY A.team
ORDER BY TOTAL_MEDALS DESC

--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years
SELECT
COUNT(AE.medal) AS TOTAL_MEDALS,
A.name
FROM athlete_events AS AE 
INNER JOIN
athletes AS A
ON AE.athlete_id = A.id
GROUP BY AE.medal,A.name
HAVING AE.medal = 'Gold'
ORDER BY TOTAL_MEDALS DESC;

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.
SELECT
COUNT(AE.medal) AS TOTAL_MEDALS,
A.name,
AE.year
FROM athlete_events AS AE 
INNER JOIN
athletes AS A
ON AE.athlete_id = A.id
GROUP BY AE.medal,A.name,AE.year
HAVING AE.medal = 'Gold'
ORDER BY TOTAL_MEDALS DESC;

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

WITH FirstMedals AS (
    SELECT
        AE.year,
        AE.sport,
        AE.medal,
        ROW_NUMBER() OVER (PARTITION BY AE.medal ORDER BY AE.year ASC) AS MedalRank
    FROM athlete_events AS AE
    INNER JOIN athletes AS A ON AE.athlete_id = A.id
    WHERE A.team = 'INDIA' AND AE.medal IN ('GOLD', 'SILVER', 'BRONZE')
)

SELECT 
    CASE 
        WHEN medal = 'GOLD' THEN 'FIRST_GOLD'
        WHEN medal = 'SILVER' THEN 'FIRST_SILVER'
        WHEN medal = 'BRONZE' THEN 'FIRST_BRONZE'
    END AS Medal,
    year,
    sport
FROM FirstMedals
WHERE MedalRank = 1
ORDER BY 
    CASE 
        WHEN medal = 'GOLD' THEN 1
        WHEN medal = 'SILVER' THEN 2
        WHEN medal = 'BRONZE' THEN 3
    END;


--6 find players who won gold medal in summer and winter olympics both.
SELECT
A.name
FROM athlete_events AS AE
INNER JOIN athletes AS A
ON AE.athlete_id = A.id
WHERE AE.medal = 'GOLD' AND AE.season IN ('SUMMER','WINTER')
GROUP BY A.name
HAVING COUNT(DISTINCT AE.season) = 2;

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
SELECT
A.name,
AE.games,
AE.year
FROM athlete_events AS AE
INNER JOIN athletes AS A
ON AE.athlete_id = A.id
WHERE AE.medal IN ('GOLD','SILVER','BRONZE')
GROUP BY A.name , AE.games,AE.year
HAVING COUNT(DISTINCT AE.medal) = 3

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event, Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
WITH ConsecutiveGoldMedals AS (
    SELECT 
        A.name,
        AE.event,
        AE.year,
        ROW_NUMBER() OVER (PARTITION BY A.name, AE.event ORDER BY AE.year) AS rn
    FROM 
        athlete_events AS AE
    INNER JOIN 
        athletes AS A ON AE.athlete_id = A.id
    WHERE 
        AE.medal = 'Gold' 
        AND AE.year IN (2000, 2004, 2008, 2012, 2016, 2020)
)
SELECT 
    C1.name,
    C1.event
FROM 
    ConsecutiveGoldMedals C1
JOIN 
    ConsecutiveGoldMedals C2 ON C1.name = C2.name AND C1.event = C2.event
JOIN 
    ConsecutiveGoldMedals C3 ON C1.name = C3.name AND C1.event = C3.event
WHERE 
    C1.rn = 1 AND C2.rn = 2 AND C3.rn = 3
    AND C2.year = C1.year + 4
    AND C3.year = C2.year + 4;