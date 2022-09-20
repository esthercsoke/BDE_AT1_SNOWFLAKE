
-- Create Database called AT1BDE
CREATE DATABASE AT1BDE;

-- Use DataBase AT1BDE
USE DATABASE AT1BDE;

-- Create storage integration with storage provider AUZRE
CREATE STORAGE INTEGRATION azure_bde_at1
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = AZURE
  ENABLED = TRUE
  AZURE_TENANT_ID = ''
  STORAGE_ALLOWED_LOCATIONS = ('');

-- initalise command to retrieve azure consent 
DESC STORAGE INTEGRATION azure_bde_at1; 

-- create storage stage
CREATE OR REPLACE STAGE stage_bde_at1
STORAGE_INTEGRATION = azure_bde_at1
URL='';


-- creating file format for csv files
CREATE OR REPLACE FILE FORMAT trending_file_format_csv 
TYPE = 'CSV' 
FIELD_DELIMITER = ',' 
SKIP_HEADER = 1
NULL_IF = ('\\N', 'NULL', 'NUL', '')
FIELD_OPTIONALLY_ENCLOSED_BY = '"';
 

-- create external table with file format, renamed columns
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending
(
VIDEO_ID varchar as (value:c1::varchar), 
TITLE varchar as (value:c2::varchar),
PUBLISHEDAT datetime as (value:c3::datetime),
CHANNELID varchar as (value:c4::varchar),
CHANNELTITLE varchar as (value:c5::varchar),
CATEGORYID int as (value:c6::int),    
TRENDING_DATE date as (value:c7::date),     
VIEW_COUNT int as (value:c8::int),
LIKES int as (value:c9::int),
DISLIKES int as (value:c10::int),
COMMENT_COUNT int as (value:c11::int),
COMMENTS_DISABLED varchar as (value:c12::varchar)
)
WITH LOCATION = @stage_bde_at1
FILE_FORMAT = trending_file_format_csv
PATTERN = '.*[.]csv';




-- create new database from ex_table_youtube_trending
-- add country column from file name
CREATE OR REPLACE TABLE table_youtube_trending AS
SELECT video_id,
       title,
       publishedat,
       channelid,
       channeltitle,
       categoryid,
       trending_date,
       view_count,
       likes,
       dislikes,
       comment_count,
       comments_disabled,
       split_part(metadata$filename, '_', 1)::VARCHAR AS country
FROM   ex_table_youtube_trending;

----------CATEGORY DATA SET UP------------------


-- CATEGORY TABLE SETUP
CREATE OR REPLACE external TABLE ex_table_youtube_category
  WITH location = @stage_bde_at1
  file_format = (type=json)
  pattern = '.*[.]json';


-- create table_youtube_category, and use lateral flatten to retrieve values
CREATE OR REPLACE TABLE table_youtube_category as 
SELECT 
split_part(metadata$filename,'_', 1)::varchar as COUNTRY,
b.value:id::int as CATEGORYID,
b.value:"snippet":"title"::varchar as CATEGORY_TITLE
FROM ex_table_youtube_category
, LATERAL FLATTEN(input => value) l, lateral flatten(input => l.value) b;



-- create new table table_youtube_final 
-- combine tables by country and categoryid
-- while adding a new field called "id" by using UUID_STRING() fuction
CREATE OR REPLACE TABLE table_youtube_final AS
SELECT    uuid_string()                     AS id,
          t.video_id,
          t.title ,
          t.publishedat,
          t.channelid,
          t.channeltitle,
          t.categoryid,
          c.category_title,
          t.trending_date,
          t.view_count,
          t.likes,
          t.dislikes,
          t.comment_count,
          t.comments_disabled,
          t.country
FROM      table_youtube_trending t
LEFT JOIN table_youtube_category c
ON        c.country = t.country
AND       c.categoryid = t.categoryid;


