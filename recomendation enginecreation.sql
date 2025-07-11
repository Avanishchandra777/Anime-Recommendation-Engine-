-- Step 1: Rename the old table
ALTER TABLE users RENAME TO users_old;

-- Step 2: Create a new table with desired column order
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    anime_id INT,
    username TEXT
);

-- Step 3: Copy data from old to new table
INSERT INTO users (user_id, anime_id, username)
SELECT user_id, anime_id, username FROM users_old;

-- Step 4: (Optional) Drop the old table
DROP TABLE users_old;

ALTER TABLE users DROP CONSTRAINT users_pkey1;
ALTER TABLE users ADD PRIMARY KEY (user_id, anime_id);



DROP TABLE IF EXISTS anime CASCADE;

CREATE TABLE anime (
    anime_id     INT PRIMARY KEY,
    anime_title  TEXT,
    genre        TEXT,
    anime_type   TEXT,
    episodes     INT,
    avg_rating   FLOAT,
    members      INT
);

select * from anime;
DROP TABLE IF EXISTS genre CASCADE;

CREATE TABLE genre2 (
    genre_id SERIAL PRIMARY KEY,
    genre_name TEXT
);
CREATE TABLE anime_genre_br2 (
    anime_id INT,
    genre_id INT,
    PRIMARY KEY (anime_id, genre_id),
    FOREIGN KEY (anime_id) REFERENCES anime(anime_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);




