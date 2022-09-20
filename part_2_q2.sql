/*SELECT country and category title, where category title only appears in 1 country*/
SELECT country,
       category_title
FROM   table_youtube_category
WHERE  category_title IN (SELECT category_title
                          FROM   table_youtube_category
                          GROUP  BY category_title
                          HAVING Count(*) = 1); 