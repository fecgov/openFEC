/* 
This is to solve ticket #3862:
Install postgres extension "unaccent" for related tsvector work
*/

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;
