 -- Update the null values in categor_title with it's categoryid value 29
UPDATE
    table_youtube_final
SET
    category_title = 29
WHERE
    category_title IS NULL;