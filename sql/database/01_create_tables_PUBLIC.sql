-- Movie database schema, extracted from the group's local import script.
-- Public-safe: data-loading paths and raw data omitted. Destructive: run only on a new/test DB.
DROP TABLE IF EXISTS movie_sales,movie_genre,movie_actor,movie_director,
 user_rating,expert_rating,overall_rating,sales,
 movie,studio,genre,actor,director CASCADE;
CREATE TABLE studio(name VARCHAR(100) NOT NULL,studio_id INTEGER PRIMARY KEY);
CREATE TABLE genre(genre VARCHAR(50) NOT NULL UNIQUE,genre_id INTEGER PRIMARY KEY);
CREATE TABLE actor(actor_id INTEGER PRIMARY KEY,first_name VARCHAR(100),last_name VARCHAR(100));
CREATE TABLE director(director_id INTEGER PRIMARY KEY,first_name VARCHAR(100),last_name VARCHAR(100));
CREATE TABLE movie(
 title VARCHAR(200) NOT NULL,runtime NUMERIC(6,1),
 url VARCHAR(255) NOT NULL,reldate DATE,awards VARCHAR(255),
 movie_id INTEGER PRIMARY KEY,studio_id INTEGER REFERENCES studio(studio_id));
CREATE TABLE sales(
 sales_id INTEGER PRIMARY KEY,title VARCHAR(300) NOT NULL,
 year INTEGER,release_date DATE,genre VARCHAR(50),
 international_box_office NUMERIC(15,2),domestic_box_office NUMERIC(15,2),
 worldwide_box_office NUMERIC(15,2),production_budget NUMERIC(15,2),
 opening_weekend NUMERIC(15,2),theatre_count INTEGER,
 avg_run_per_theatre NUMERIC(8,2),runtime NUMERIC(6,1),creative_type VARCHAR(50));
CREATE TABLE overall_rating(
 metascore INTEGER CHECK(metascore BETWEEN 0 AND 100),
 userscore_100 INTEGER CHECK(userscore_100 BETWEEN 0 AND 100),
 movie_id INTEGER PRIMARY KEY REFERENCES movie(movie_id));
CREATE TABLE user_rating(
 movie_id INTEGER NOT NULL REFERENCES movie(movie_id),
 score NUMERIC(5,1) CHECK(score BETWEEN 0 AND 100),
 datep DATE,review_id INTEGER PRIMARY KEY);
CREATE TABLE expert_rating(
 movie_id INTEGER REFERENCES movie(movie_id),
 score NUMERIC(5,1) CHECK(score BETWEEN 0 AND 100),
 datep DATE,review_id INTEGER PRIMARY KEY);
CREATE TABLE movie_genre(
 movie_id INTEGER REFERENCES movie(movie_id),
 genre_id INTEGER REFERENCES genre(genre_id),
 PRIMARY KEY(movie_id,genre_id));
CREATE TABLE movie_actor(
 movie_id INTEGER REFERENCES movie(movie_id),
 actor_id INTEGER REFERENCES actor(actor_id),
 PRIMARY KEY(movie_id,actor_id));
CREATE TABLE movie_director(
 movie_id INTEGER REFERENCES movie(movie_id),
 director_id INTEGER REFERENCES director(director_id),
 PRIMARY KEY(movie_id,director_id));
CREATE TABLE movie_sales(
 movie_id INTEGER REFERENCES movie(movie_id),
 sales_id INTEGER REFERENCES sales(sales_id),
 PRIMARY KEY(movie_id,sales_id));
