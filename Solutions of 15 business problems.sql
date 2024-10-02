-- Netflix Data Analysis using MYSQL
-- Solutions of 15 business problems
-- 1. Count the number of Movies vs TV Shows
-- use Nflix;
-- select	* from netflix;

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1

-- 2. Find the most common rating for movies and TV shows
With Ranked_Ratings AS (
    SELECT
        type,
        rating,
        COUNT(*) AS rating_count,
        ROW_NUMBER() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rnum
        FROM netflix
        GROUP BY type, rating   
)
SELECT type,rating AS most_frequent_rating
FROM Ranked_Ratings
WHERE rnum = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix
-- postgres
-- SELECT country, UNNEST(STRING_TO_ARRAY(country, ',')) as country, COUNT(*) as total_content FROM netflix 
-- GROUP BY 1 order by total_content
SELECT 
  country, 
  COUNT(*) as total_content
FROM (
  SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n.n), ',', -1)) AS country
  FROM netflix
  JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
  ) n ON LENGTH(country) - LENGTH(REPLACE(country, ',', '')) >= n.n - 1 
) as t1
-- WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie

-- SELECT * 
-- FROM netflix 
-- WHERE type = 'Movie' 
-- ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;

SELECT * 
FROM netflix 
WHERE type = 'Movie' 
and duration = (select max(duration) from netflix);

-- 6. Find content added in the last 5 years
SELECT * 
FROM netflix 
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * 
FROM netflix 
WHERE LOWER(director) LIKE '%rajiv chilaka%';

-- 7(b) Find all the movies/TV shows count by director 'Rajiv Chilaka'!

SELECT director, COUNT(*) AS total_movies 
FROM netflix 
WHERE LOWER(director) LIKE '%rajiv chilaka%' 
GROUP BY director;

-- 8. List all TV shows with more than 5 seasons
SELECT * 
FROM netflix 
WHERE TYPE = 'TV Show' 
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;

-- 9. Count the number of content items in each genre
WITH genre_split AS (
    SELECT show_id,
	TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) AS genre
    FROM netflix
    JOIN (
        SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION 
        SELECT 5 UNION SELECT 6 UNION SELECT 7
    ) numbers ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= numbers.n - 1
)
SELECT genre, COUNT(*) AS total_content
FROM genre_split
WHERE genre IS NOT NULL AND genre != ''
GROUP BY genre
ORDER BY total_content DESC;

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
SELECT 
  YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year,
  COUNT(*) AS yearly_content,
  ROUND(
    COUNT(*) / (SELECT COUNT(*) FROM netflix WHERE country = 'India') * 100
  ) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY YEAR(STR_TO_DATE(date_added, '%M %d, %Y'))
order by year;

-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE lower(listed_in) LIKE '%Documentaries';

-- 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * 
FROM netflix 
WHERE cast LIKE '%Salman Khan%' 
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', n.n), ',', -1) as actor,COUNT(*) 
FROM netflix 
CROSS JOIN (SELECT a.N + b.N * 10 + 1 n FROM (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a ,(SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b ORDER BY n) n
WHERE country = 'India' 
AND n.n <= 1 + (LENGTH(cast) - LENGTH(REPLACE(cast, ',', '')))
GROUP BY actor 
ORDER BY COUNT(*) DESC LIMIT 10;

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
SELECT 
  category, 
  TYPE, 
  COUNT(*) AS content_count 
FROM (
  SELECT 
    *, 
    CASE 
      WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad' 
      ELSE 'Good' 
    END AS category 
  FROM 
    netflix 
) AS categorized_content 
GROUP BY 1, 2 
ORDER BY 2;

-- End of reports

