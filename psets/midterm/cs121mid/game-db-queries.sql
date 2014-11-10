-- [Problem 2]
SELECT person_id, person_name
FROM geezer NATURAL JOIN game_score NATURAL JOIN game
GROUP BY person_id, person_name
HAVING SUM(type_id) =
    (SELECT COUNT(type_id)
    FROM game_type);


-- [Problem 3]
CREATE VIEW top_scores AS
    SELECT type_id, type_name, person_id, person_name, score
    FROM geezer NATURAL JOIN game_type NATURAL JOIN game NATURAL JOIN game_score
    WHERE (type_id, type_name, score) IN
        (SELECT type_id, type_name, MAX(score) AS score
        FROM game_score NATURAL JOIN game NATURAL JOIN game_type
        GROUP BY type_id, type_name)
    ORDER BY type_id;


-- [Problem 4]
CREATE VIEW recent_num_games AS
    SELECT type_id, COUNT(game_id) AS num_games
    FROM game
    WHERE game_date BETWEEN NOW() - INTERVAL 2 WEEK AND NOW()
    GROUP BY type_id;

SELECT type_id
FROM recent_num_games
WHERE num_games >
    (SELECT AVG(num_games) AS avg_num_games
    FROM recent_num_games);

-- [Problem 5]
CREATE TEMPORARY TABLE game_score_old (
    game_id         INTEGER NOT NULL,
    person_id       INTEGER NOT NULL,
    score           INTEGER NOT NULL,
);

INSERT INTO game_score_old
    SELECT *
    FROM game_score;

DELETE FROM game_score
WHERE game_id IN
    (SELECT game_id
    FROM game NATURAL JOIN game_type
    WHERE type_name = "cribbage")
AND person_id IN
    (SELECT person_id
    FROM game_score NATURAL JOIN geezer
    WHERE person_name = "Ted Codd");

DELETE FROM game
WHERE type_id IN
    (SELECT type_id
    FROM game_type
    WHERE type_name = "cribbage")
AND game_id IN
    (SELECT game_id
    FROM game_score_old NATURAL JOIN geezer
    WHERE person_name = "Ted Codd");


-- [Problem 6]
UPDATE geezer
SET prescriptions = CONCAT(prescriptions, 'Extra Pudding on Thursdays!');

UPDATE geezer
SET prescriptions = 'Extra Pudding on Thursdays!'
WHERE prescriptions IS NULL;


-- [Problem 7]
SELECT person_id, person_name, COUNT(points) AS total_points
FROM
    (SELECT person_id, person_name, CASE
        WHEN score > (SELECT MAX(score) AS max_score
                     FROM game_score
                     WHERE game_id = g.game_id AND person_id != g.person_id)
                     THEN 1
        WHEN score = (SELECT MAX(score) AS max_score
                     FROM game_score
                     WHERE game_id = g.game_id AND person_id != g.person_id)
                     THEN .5
        ELSE 0
        END
    AS points
    FROM game_score AS g NATURAL JOIN game NATURAL JOIN game_type
    WHERE game_type.min_players > 1) AS game_points
ORDER BY total_points DESC;
