-- Check category_title duplicates, not accounting for categoryid
SELECT country,
       category_title,
       Count(category_title) AS title_count
FROM   table_youtube_category
GROUP  BY category_title,
          country
HAVING Count(category_title) > 1; 
