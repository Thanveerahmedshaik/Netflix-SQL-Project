# Netflix Movies and TV Shows Data Analysis using SQL

![](
## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
        description    VARCHAR(250)    
);
```

## Business Problems and Solutions

**Objective:** Determine the distribution of content types on Netflix.
### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type, COUNT(*) as total_content
FROM netflix
GROUP BY type;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;
```

**Objective:** Retrieve all movies released in a specific year.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * FROM netflix
WHERE 
    type = 'Movie'
    AND
    release_year = 2021;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 4. Find the Top 5 Countries with the Most Content on Netflix



```sql
/* 
Approach : Lets use string to array function here -> unnest the array using UNNEST()
Function*/
SELECT 
      UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
      COUNT(show_id) as total_content        
FROM netflix
GROUP by 1
ORDER BY total_content DESC
LIMIT 5;
```

**Objective:** Find the movie with the longest duration.

### 5. Identify the Longest Movie

```sql
SELECT title,
        MAX(CAST(SUBSTRING(duration,1,POSITION(' ' IN duration)-1) AS INT)) AS maximum_length
FROM netflix
WHERE
    type = 'Movie' and duration is not null
GROUP BY 1
ORDER BY 2 DESC
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT * FROM netflix
WHERE 
TO_DATE(date_added, 'MONTH DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'

```

**Objective:** Identify TV shows with more than 5 seasons.

### 8. List All TV Shows with More Than 5 Seasons

```sql
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

```

**Objective:** Count the number of content items in each genre.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT  UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS GENRE,
        COUNT(netflix.show_id) AS total_count
FROM netflix
GROUP BY 1;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
    country,
    EXTRACT(YEAR FROM TO_DATE(date_added, 'MONTH DD, YYYY')) as year,
    COUNT(*) AS yearly_content,
    ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India') * 100, 2) as avg_content_per_year 
    FROM netflix
WHERE country = 'India'
GROUP BY 1,2
ORDER BY avg_content_per_year DESC
LIMIT 5; 
```

**Objective:** Retrieve all movies classified as documentaries.

### 11. List All Movies that are Documentaries

```sql
SELECT  show_id,
        title,
        listed_in 
        FROM netflix
WHERE 
        listed_in ILIKE '%Documen%';

```

**Objective:** List content that does not have a director.

### 12. Find All Content Without a Director

```sql
SELECT * FROM netflix
WHERE director IS NULL;

```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * FROM netflix
WHERE 
    casts ILIKE '%Salman Khan%'
    AND 
    netflix.release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10 ;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
WITH new_table
AS
(
SELECT 
*,
        CASE 
        WHEN description ILIKE '%kill%' OR 
             description ILIKE '%Violence%' THEN 'Violent_content'
             ELSE 'Good_content'
        END category
FROM netflix
)
SELECT 
      category,
      COUNT(*) AS total_content
FROM new_table
GROUP BY 1;
```



## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.





## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/Thanveerahmedshaik/Netflix-SQL-Project.git
   ```
2. **Set Up the Database**: Execute the SQL scripts in the `netflix_db.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Thanveer Ahmed Shaik

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!


- **LinkedIn**: [linkedin.com/in/thanveer-ahmed-shaik/](https://www.linkedin.com/in/thanveer-ahmed-shaik/)
- **Mail**: **shaikthanveerahmed123@gmail.com**


Thank you for your interest in this project!
