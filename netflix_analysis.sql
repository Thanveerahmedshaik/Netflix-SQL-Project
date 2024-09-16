--NETFLIX DATA ANALYSIS

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix(
		show_id VARCHAR(6),
		type VARCHAR(10),
		title VARCHAR(150),
		director VARCHAR(208),
		casts VARCHAR(1000),
		country VARCHAR(150),
		date_added VARCHAR(50),
		release_year INT,
		rating VARCHAR(10),
		duration VARCHAR(15),
		listed_in VARCHAR(100),
		description	VARCHAR(250)	
)


SELECT * FROM netflix


SELECT COUNT(*) as total_count FROM netflix

SELECT DISTINCT type FROM netflix


--15 Business Problems


-- 1. Count the number of movues vs TV Shows

SELECT * FROM netflix

SELECT type, COUNT(*) as total_content
FROM netflix
GROUP BY type


--2. Find the most common ratings for the movies and TV shows
SELECT type , ranking 
FROM 
(
	SELECT 
		type, 
		rating, 
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY type, rating
) as t1 
WHERE ranking = 1
-- ORDER BY COUNT(*) DESC


--3. List all the movies that is released in a specific year(Ex: 2021)
/*
Approach: filter data by date(2021) --> filter movies
*/


SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2021
	
--4. Find the top 5 countries with the most content on netflix
/* 
Approach : Lets use string to array function here -> unnest the array using UNNEST()
Function*/



SELECT 
		UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
		COUNT(show_id) as total_content		
FROM netflix
GROUP by 1
ORDER BY total_content DESC
LIMIT 5


--5. Identify the longest movie?
/*
The duration column is in text so lets convert it into number format first
->get the substring(e.g: 90 min -> 90) -> typecast it to int -> Find the maximum
*/

SELECT title,
		MAX(CAST(SUBSTRING(duration,1,POSITION(' ' IN duration)-1) AS INT)) AS maximum_length
FROM netflix
WHERE
	type = 'Movie' and duration is not null
GROUP BY 1
ORDER BY 2 DESC


--6.Find the content added in the last 5 years
SELECT * FROM netflix
WHERE 
TO_DATE(date_added, 'MONTH DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'



--7.Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'



--8.List all TV Shows with more than or equals to 5 season


--Approach 1:

SELECT * FROM netflix
WHERE 
	type = 'TV Show'
	AND
	CAST(SUBSTRING(duration, 1, POSITION(' ' IN duration)-1) AS INT) >=5;


--Approach 2: Using SPLIT_PART function

SELECT * FROM netflix
WHERE 
	type = 'TV Show'
	AND 
	SPLIT_PART(duration, ' ', 1)::numeric >= 5;




--9. Count the number of content items in each genre
SELECT  UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS GENRE,
		COUNT(netflix.show_id) AS total_count
FROM netflix
GROUP BY 1;


--10.Find each year and average number of content release in  India on netflix.
--return top 5 with highest avg content release

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'MONTH DD, YYYY')) as year,
	COUNT(*) AS yearly_content,
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India') * 100, 2) as avg_content_per_year 
	FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY year; 


--11.List all the movies that are documentaries


SELECT  show_id,
		title,
		listed_in 
		FROM netflix
WHERE 
		listed_in ILIKE '%Documen%';



--12. Find all the content without a director


SELECT * FROM netflix
WHERE director IS NULL;


--13. Find how many movies actor Salman Khan appeared in last 10 years

SELECT * FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND 
	netflix.release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10 



--14. Find the top 10 actors who have appeared in the highest number of movies produced in India
/*
Approach:
IF u see the casts column they have multiple cast in the same row so the logic we are going to try here is 
we will extract each cast in an array and duplicate the film to each cast i.e, Based on each cast we create a film 
*/

SELECT 
	   --show_id,
	   --casts,
	   UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
	   COUNT(*) as num_of_movies
	   FROM netflix
	   WHERE country ILIKE '%india'
	   GROUP BY actors
	   ORDER BY COUNT(*) DESC
	   LIMIT 10;
	   


/*15.Categorize the content based on the presence of the keywords 'kill' and 'violence in ' in the 
description field. Label content containing these keywords as 'Bad' and all other content as 'Good.
Count how many items fall into each category'*/

WITH new_table
AS
(
SELECT 
*,
		CASE 
		WHEN description ILIKE 'kill%' OR 
	         description ILIKE '%Violence%' THEN 'Violent_content'
			 ELSE 'Good_content'
		END category
		FROM netflix
)
SELECT 
	  category,
	  COUNT(*) AS total_content
FROM new_table
GROUP BY 1





	











