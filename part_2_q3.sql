/* Select the categoryid where the category_title is NULL */
SELECT categoryid
FROM   table_youtube_final
WHERE  category_title IS NULL
GROUP  BY categoryid;