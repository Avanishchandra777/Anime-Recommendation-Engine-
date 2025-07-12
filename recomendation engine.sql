--Top 10 Highest Rated Anime (with at least 1000 ratings)
SELECT 
    a.anime_title,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.rating) AS rating_count
FROM ratings r
JOIN anime a ON a.anime_id = r.anime_id
WHERE r.rating > 0
GROUP BY a.anime_title
HAVING COUNT(r.rating) >= 1000
ORDER BY avg_rating DESC
LIMIT 10;

--Most Popular Genres by Total Ratings
SELECT 
    g.genre_name,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(*) AS total_ratings
FROM ratings r
JOIN anime_genre_bridge2 agb ON r.anime_id = agb.anime_id
JOIN genre2 g ON agb.genre_id = g.genre_id
WHERE r.rating > 0
GROUP BY g.genre_name
ORDER BY avg_rating DESC;




--Top 5 Active Users (by number of ratings given)
SELECT 
    u.username,
    COUNT(r.rating) AS ratings_given
FROM ratings r
JOIN users u ON r.user_id = u.user_id
GROUP BY u.username
ORDER BY ratings_given DESC
LIMIT 5;


--Most Watched Anime (by number of users who rated it)
SELECT 
    a.anime_title,
    COUNT(DISTINCT r.user_id) AS unique_viewers
FROM ratings r
JOIN anime a ON r.anime_id = a.anime_id
GROUP BY a.anime_title
ORDER BY unique_viewers DESC
LIMIT 10;


--Average Rating Per Genre
SELECT 
    g.genre_name,
    ROUND(AVG(r.rating), 2) AS avg_genre_rating
FROM ratings r
JOIN anime_genre_bridge2 agb ON r.anime_id = agb.anime_id
JOIN genre2 g ON agb.genre_id = g.genre_id
WHERE r.rating > 0
GROUP BY g.genre_name
ORDER BY avg_genre_rating DESC;


--Anime with the Most Genres
SELECT 
    a.anime_title,
    COUNT(agb.genre_id) AS genre_count
FROM anime a
JOIN anime_genre_bridge2 agb ON a.anime_id = agb.anime_id
GROUP BY a.anime_title
ORDER BY genre_count DESC
LIMIT 10;

select * from fact_anime_ratings;

--RECOMMENDATION ENGINE
-- Step 1: Get genres of anime user rated highly
WITH user_fav_anime AS (
  SELECT a.anime_id, a.genre
  FROM anime a
  JOIN fact_anime_ratings r ON a.anime_id = r.anime_id
  WHERE r.user_id = 123 AND r.rating >= 8
),
user_genres AS (
  SELECT DISTINCT UNNEST(string_to_array(genre, ', ')) AS genre
  FROM user_fav_anime
),
similar_anime AS (
  SELECT DISTINCT a.anime_id, a.anime_title
  FROM anime a
  JOIN (
    SELECT anime_id, UNNEST(string_to_array(genre, ', ')) AS genre
    FROM anime
  ) ag ON ag.anime_id = a.anime_id
  WHERE ag.genre IN (SELECT genre FROM user_genres)
),
user_watched AS (
  SELECT anime_id
  FROM fact_anime_ratings
  WHERE user_id = 123
),
anime_avg_ratings AS (
  SELECT anime_id, ROUND(AVG(rating), 2) AS avg_rating
  FROM fact_anime_ratings
  GROUP BY anime_id
)
SELECT sa.anime_id, sa.anime_title, ar.avg_rating
FROM similar_anime sa
JOIN anime_avg_ratings ar ON sa.anime_id = ar.anime_id
WHERE sa.anime_id NOT IN (SELECT anime_id FROM user_watched)
ORDER BY ar.avg_rating DESC NULLS LAST
LIMIT 10;


select * from users

WITH user_fav_anime AS (
  SELECT r.anime_id
  FROM fact_anime_ratings r
  WHERE r.user_id = 123 AND r.rating >= 8
),
user_genres AS (
  SELECT DISTINCT agb.genre_id
  FROM user_fav_anime ufa
  JOIN anime_genre_bridge2 agb ON ufa.anime_id = agb.anime_id
),
similar_anime AS (
  SELECT DISTINCT agb.anime_id
  FROM anime_genre_bridge2 agb
  WHERE agb.genre_id IN (SELECT genre_id FROM user_genres)
),
user_watched AS (
  SELECT anime_id
  FROM fact_anime_ratings
  WHERE user_id = 123
),
anime_avg_ratings AS (
  SELECT anime_id, ROUND(AVG(rating), 2) AS avg_rating
  FROM fact_anime_ratings
  GROUP BY anime_id
)
SELECT a.anime_id, a.anime_title, ar.avg_rating
FROM anime a
JOIN anime_avg_ratings ar ON a.anime_id = ar.anime_id
WHERE a.anime_id IN (SELECT anime_id FROM similar_anime)
  AND a.anime_id NOT IN (SELECT anime_id FROM user_watched)
ORDER BY ar.avg_rating DESC NULLS LAST
LIMIT 10;

--a
WITH anime_avg_ratings AS (
  SELECT anime_id, ROUND(AVG(rating), 2) AS avg_rating
  FROM fact_anime_ratings
  GROUP BY anime_id
)
SELECT a.anime_id, a.anime_title, ar.avg_rating
FROM anime a
JOIN anime_avg_ratings ar ON a.anime_id = ar.anime_id
ORDER BY ar.avg_rating DESC NULLS LAST
LIMIT 10;


--Recomedation based on genre
WITH action_anime AS (
  SELECT a.anime_id, a.anime_title
  FROM anime a
  JOIN anime_genre_bridge2 agb ON a.anime_id = agb.anime_id
  JOIN genre2 g ON agb.genre_id = g.genre_id
  WHERE g.genre_name = 'Action'
),
anime_avg_ratings AS (
  SELECT anime_id, ROUND(AVG(rating), 2) AS avg_rating
  FROM fact_anime_ratings
  GROUP BY anime_id
)
SELECT aa.anime_id, aa.anime_title, ar.avg_rating
FROM action_anime aa
JOIN anime_avg_ratings ar ON aa.anime_id = ar.anime_id
ORDER BY ar.avg_rating DESC NULLS LAST
LIMIT 10;




