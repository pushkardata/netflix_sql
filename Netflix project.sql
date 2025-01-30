-- Netflix project
DROP TABLE IF EXSITS netflix;
CREATE TABLE netflix
(
 show_id VARCHAR(6),
 type VARCHAR(10),
 title VARCHAR(150),
 director VARCHAR(208),
 castS VARCHAR(1000),
 country VARCHAR(150),
 date_added VARCHAR(50),
 release_year INT,
 rating	VARCHAR(10),
 duration VARCHAR(15),
 listed_in VARCHAR(100),
 description VARCHAR(250)
);

SELECT 
*
FROM netflix;

-- 15 Business Problems
-- 1. Cont the number of movies and number of TV shows

SELECT
 type,
 COUNT (*) AS total_content
FROM netflix
GROUP BY type

-- 2. Find the most common rating for the Movies and the TV shows

SELECT
 type,
 rating
FROM
(
  SELECT
    type,
	rating,
	COUNT(*),
	RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
  FROM netflix
  GROUP BY 1,2
) as t1
WHERE 
  ranking = 1

-- 3. List all the MOvies release in the year 2020 

SELECT * FROM netflix
WHERE 
 type = 'Movie'
 AND
 release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix


SELECT 
  UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
  COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 5. Identify the longest Movie

SELECT * FROM netflix
 WHERE 
      type = 'Movie'
	  AND
	  duration = (SELECT MAX(duration)FROM netflix)

--6. Find the content that added in last 5 years 

SELECT * FROM netflix
WHERE 
  TO_DATE(date_added, 'Month DD,YYYY')>=CURRENT_DATE - INTERVAL '5 years'

--7. Find all the movies nad TV shows by the director 'Rajiv Chilaka'

SELECT * FROM netflix
WHERE 
 director ILIKE '%Rajiv Chilaka%'

--8. List all the TV shows which have more than 5 seasons

SELECT * FROM netflix
WHERE 
  type = 'TV Show'
  AND
  SPLIT_PART(duration,' ',1)::numeric > 5

-- 9. Count the number of content item in each Genre

SELECT
  UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
  COUNT(show_id) as total_content
FROM netflix
GROUP BY 1

-- 10. Find each year and the average number of content release in India on netflix return top 5 year with highest avg content release

SELECT
  EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYYY')) as year,
  COUNT(*) as yearly_content,
  ROUND(
  COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE countrY = 'India') ::numeric * 100,2
  ) as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1 
ORDER BY yearly_content DESC
LIMIT 5;

-- 11. List all movies that are documentries

SELECT * FROM netflix
WHERE 
  listed_in ILIKE '%documentaries%'

-- 12. Find all the content without director 

SELECT * FROM netflix
WHERE 
  director is NULL

-- Find how many movies actor 'Salman Khan' appeared in last 10 years 

SELECT * FROM netflix
WHERE 
 casts ILIKE '%Salman Khan%'
 AND
 release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find top 10 actors who have appeared in th highest number of movies produced in India 

SELECT
UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- 15. Categorize the contenet based on the presence of key word kill or violence in the description field. Label the content containning these key word as Negative and all other content as positive. Count how many items fall into each category

WITH category_table
AS
(
SELECT
*,
  CASE
  WHEN
      description ILIKE '%kill%' OR
	  description ILIKE '%violence%' THEN 'Negative content'
	  ELSE 'positive content'
  END category
FROM netflix
)
SELECT
      category,
	  COUNT(*) as tota_content
FROM category_table
GROUP BY 1