/* Create new table, partition by video_id, trending_date, country, order by view_count
and select only row_numbers above 1 to store duplicates */
CREATE OR REPLACE TABLE table_youtube_duplicates AS
SELECT *
FROM   (
                SELECT   *,
                         row_number() over ( partition BY video_id, trending_date, country ORDER BY view_count DESC) rownumber
                FROM     table_youtube_final) a
WHERE  a.rownumber > 1;