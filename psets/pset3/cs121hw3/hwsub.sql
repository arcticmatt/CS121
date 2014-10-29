-- [Problem 1a]
SELECT SUM(perfectscore) AS sum_perfectscore
FROM assignment;


-- [Problem 1b]
SELECT sec_name, COUNT(DISTINCT username) AS num_students
FROM section NATURAL JOIN student
GROUP BY sec_name;


-- [Problem 1c]
CREATE VIEW totalscores AS
    SELECT username, SUM(score) AS total_score
    FROM submission
    WHERE graded = 1
    GROUP BY username;


-- [Problem 1d]
CREATE VIEW passing AS
    SELECT *
    FROM totalscores
    WHERE total_score >= 40;


-- [Problem 1e]
CREATE VIEW failing AS
    SELECT *
    FROM totalscores
    WHERE total_score < 40;


-- [Problem 1f]
-- I got 11 names: harris, ross, miller, turner, edwards, murphy, simmons,
-- tucker, coleman, flores, gibson
SELECT DISTINCT username
FROM submission NATURAL JOIN assignment
WHERE shortname LIKE 'lab%' AND sub_id NOT IN
    (SELECT sub_id
    FROM fileset)
AND username IN
    (SELECT username
    FROM passing);


-- [Problem 1g]
-- I got 1 name, collins.
SELECT DISTINCT username
FROM submission NATURAL JOIN assignment
WHERE (shortname = 'Midterm' OR shortname = 'Final') AND sub_id NOT IN
    (SELECT sub_id
    FROM fileset)
AND username IN
    (SELECT username
    FROM passing);


-- [Problem 2a]
SELECT DISTINCT username
FROM fileset NATURAL JOIN assignment NATURAL JOIN submission
WHERE shortname = 'Midterm' AND fileset.sub_date > assignment.due;


-- [Problem 2b]
SELECT EXTRACT(HOUR FROM sub_date) AS hour, COUNT(sub_id) AS num_submits
FROM fileset NATURAL JOIN assignment NATURAL JOIN submission
WHERE shortname LIKE 'lab%'
GROUP BY EXTRACT(HOUR FROM sub_date);


-- [Problem 2c]
SELECT COUNT(*) num_risky_finals
FROM fileset NATURAL JOIN assignment NATURAL JOIN submission
WHERE shortname = 'Final' AND
sub_date BETWEEN due - INTERVAL 30 MINUTE AND due;


-- [Problem 3a]
ALTER TABLE student ADD COLUMN email VARCHAR(200);
UPDATE student
    set email = CONCAT(username, '@school.edu');
ALTER TABLE student MODIFY COLUMN email VARCHAR(200) NOT NULL;


-- [Problem 3b]
ALTER TABLE assignment ADD COLUMN submit_files BOOLEAN DEFAULT TRUE;
UPDATE assignment
    set submit_files = FALSE
WHERE shortname LIKE 'dq%';


-- [Problem 3c]
CREATE TABLE gradescheme (
    scheme_id    INTEGER,
    scheme_desc  VARCHAR(100) NOT NULL,
    PRIMARY KEY (scheme_id)
);
INSERT INTO gradescheme VALUES (0, 'Lab assignment with min-grading.');
INSERT INTO gradescheme VALUES (1, 'Daily quiz.');
INSERT INTO gradescheme VALUES (2, 'Midterm or final exam.');
ALTER TABLE assignment CHANGE COLUMN gradescheme scheme_id INTEGER NOT NULL;
ALTER TABLE assignment
    ADD FOREIGN KEY (scheme_id)
    REFERENCES gradescheme(scheme_id);


-- [Problem 4a]
DELIMITER !

-- Given a date value, returns TRUE if it is a weekend, or FALSE if it is
-- a weekday
CREATE FUNCTION is_weekend(d DATE) RETURNS BOOLEAN
BEGIN
    IF dayofweek(d) = 7 THEN RETURN TRUE;
    ELSEIF dayofweek(d) = 1 THEN RETURN TRUE;
    END IF;
    RETURN FALSE;
END!

DELIMITER ;


-- [Problem 4b]
DELIMITER !

-- Given a date value, returns TRUE if it is a weekend, or FALSE if it is
-- a weekday
CREATE FUNCTION is_holiday(d DATE) RETURNS VARCHAR(20) BEGIN
    IF dayofyear(d) = 1 THEN RETURN 'New Year\'s Day';
    ELSEIF dayofmonth(d) BETWEEN 25 AND 31 AND dayofweek(d) = 2 AND
        month(d) = 5 THEN RETURN 'Memorial Day';
    ELSEIF dayofmonth(d) = 4 AND month(d) = 7 THEN RETURN 'Independence Day';
    ELSEIF dayofmonth(d) BETWEEN 1 AND 7 AND dayofweek(d) = 2 AND month(d) = 9
        THEN RETURN 'Labor Day';
    ELSEIF dayofmonth(d) BETWEEN 22 AND 28 AND dayofweek(d) = 5
        AND month(d) = 11 THEN RETURN 'Thanksgiving';
    ELSE RETURN NULL;
    END IF;
END!

DELIMITER ;


-- [Problem 5a]
SELECT is_holiday(DATE(sub_date)) AS holiday, COUNT(sub_id) AS num_submits
FROM fileset
GROUP BY is_holiday(DATE(sub_date));


-- [Problem 5b]
SELECT CASE
    WHEN is_weekend(DATE(sub_date)) = FALSE THEN 'weekday'
    ELSE 'weekend'
    END AS day_type, COUNT(sub_id) AS num_submits
FROM fileset
GROUP BY is_weekend(DATE(sub_date));
