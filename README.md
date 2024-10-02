# Netflix Movies and TV Shows Data Analysis using SQL

![]()

## Project Overview
This project analyzes Netflix's movies and TV shows data using SQL to extract valuable insights and answer business questions.

## Objectives
Analyze content types (movies vs TV shows)
Identify common ratings
Examine release years, countries, and durations
Categorize content by specific criteria and keywords

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix
```sql
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

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql

-- SELECT * 
-- FROM netflix 
-- WHERE type = 'Movie' 
-- ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;

SELECT * 
FROM netflix 
WHERE type = 'Movie' 
and duration = (select max(duration) from netflix);
```
**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT * 
FROM netflix 
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;
```
**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT * 
FROM netflix 
WHERE LOWER(director) LIKE '%rajiv chilaka%';
```
**Objective:** List all content directed by 'Rajiv Chilaka'.

### 7(b) Find all the movies/TV shows count by director 'Rajiv Chilaka'!
```sql
SELECT director, COUNT(*) AS total_movies 
FROM netflix 
WHERE LOWER(director) LIKE '%rajiv chilaka%' 
GROUP BY director;
```
### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT * 
FROM netflix 
WHERE TYPE = 'TV Show' 
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;
```
**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
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
```
**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```
**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * FROM netflix
WHERE lower(listed_in) LIKE '%Documentaries';

```
**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * FROM netflix
WHERE director IS NULL
```
**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * 
FROM netflix 
WHERE cast LIKE '%Salman Khan%' 
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```
**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', n.n), ',', -1) as actor,COUNT(*) 
FROM netflix 
CROSS JOIN (SELECT a.N + b.N * 10 + 1 n FROM (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a ,(SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b ORDER BY n) n
WHERE country = 'India' 
AND n.n <= 1 + (LENGTH(cast) - LENGTH(REPLACE(cast, ',', '')))
GROUP BY actor 
ORDER BY COUNT(*) DESC LIMIT 10;
```
**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

##Key Takeaways and Conclusion

Our analysis of the Netflix dataset has yielded several valuable insights into the platform's content offerings. The main findings can be summarized as follows:

Diverse Content Portfolio: The dataset reveals a wide range of movies and TV shows with varying ratings and genres, catering to diverse audience preferences.
Ratings Analysis: By examining the most common ratings, we gain a deeper understanding of the target audience and the types of content that resonate with them.
Regional Content Trends: Our analysis highlights the top countries with the most content releases, with a special focus on India's average content releases, providing a glimpse into regional content distribution patterns.
Content Classification: By categorizing content based on specific keywords, we can better understand the nature and themes of the content available on Netflix.
Conclusion

This comprehensive analysis provides a nuanced understanding of Netflix's content landscape, offering actionable insights that can inform content strategy and decision-making. By leveraging these findings, content creators and stakeholders can make data-driven decisions to optimize their content offerings and better serve their target audience.
