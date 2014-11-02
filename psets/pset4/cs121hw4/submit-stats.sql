-- [Problem 1]
DELIMITER !

DROP FUNCTION IF EXISTS min_submit_interval;
CREATE FUNCTION min_submit_interval(passed_id INTEGER) RETURNS INTEGER
BEGIN
    -- Variables to store values into
    DECLARE first_val INTEGER;  -- store current date value here
    DECLARE second_val INTEGER; -- store next date value here
    DECLARE diff INTEGER;
    DECLARE min_diff INTEGER DEFAULT NULL;

    -- Cursor, and flag for when fetching is done.
    DECLARE done INT DEFAULT 0;
    DECLARE cur CURSOR FOR
        SELECT UNIX_TIMESTAMP(sub_date) AS sub_date
        FROM fileset
        WHERE sub_id = passed_id ORDER BY sub_date;
    -- When fetch is complete, handler sets flag.
    -- 0200 is MySql error for "zero rows fetched."
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
        SET done = 1;

    -- Open cur, loop through cur to find min_diff, close cur
    OPEN cur;
    FETCH cur INTO first_val;
    WHILE NOT done DO
        FETCH cur INTO second_val;
        -- Avoid using a null second_val
        IF NOT done THEN
            SET diff = second_val - first_val;
            -- The default value for min_diff is NULL, so take care of that
            IF diff < IFNULL(min_diff, 2147483647) THEN SET min_diff = diff;
            END IF;
            SET first_val = second_val;
        END IF;
    END WHILE;
    CLOSE cur;
    RETURN min_diff;
END!

DELIMITER ;

-- TEST QUERIES
-- select UNIX_TIMESTAMP(sub_date) from fileset where sub_id = 3798;
-- select sub_id, min_submit_interval(sub_id) from fileset order by sub_id;

-- [Problem 2]
DELIMITER !

DROP FUNCTION IF EXISTS max_submit_interval;
CREATE FUNCTION max_submit_interval(passed_id INTEGER) RETURNS INTEGER
BEGIN
    -- Variables to store values into
    DECLARE first_val INTEGER;
    DECLARE second_val INTEGER;
    DECLARE diff INTEGER;
    DECLARE max_diff INTEGER DEFAULT NULL;

    -- Cursor, and flag for when fetching is done
    DECLARE done INT DEFAULT 0;
    DECLARE cur CURSOR FOR
        SELECT UNIX_TIMESTAMP(sub_date) AS sub_date
        FROM fileset
        WHERE sub_id = passed_id ORDER BY sub_date;
    -- When fetch is ocmplete, handler sets flag.
    -- 0200 is MySql error for "zero rows fetched."
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
        SET done = 1;

    -- Open cur, loop through cur to find max_diff, close cur
    OPEN cur;
    FETCH cur INTO first_val;
    WHILE NOT done DO
        FETCH cur INTO second_val;
        -- Avoid using a null second_val
        IF NOT done THEN
            SET diff = second_val - first_val;
            -- The default value for max_diff is NULL, so take care of that
            IF diff > IFNULL(max_diff, 0) THEN SET max_diff = diff;
            END IF;
            SET first_val = second_val;
        END IF;
    END WHILE;
    CLOSE cur;
    RETURN max_diff;
END!

DELIMITER ;

-- TEST QUERY
-- select sub_id, max_submit_interval(sub_id) from fileset order by sub_id;

-- [Problem 3]
DELIMITER !

DROP FUNCTION IF EXISTS avg_submit_interval;
CREATE FUNCTION avg_submit_interval(passed_id INTEGER) RETURNS DOUBLE BEGIN
    DECLARE max_date INTEGER;
    DECLARE min_date INTEGER;
    -- The number of dates (one more than the number of intervals)
    DECLARE count_dates INTEGER;
    DECLARE avg_interval DOUBLE;

    SELECT UNIX_TIMESTAMP(MAX(sub_date)) INTO max_date
    FROM fileset
    WHERE sub_id = passed_id;

    SELECT UNIX_TIMESTAMP(MIN(sub_date)) INTO min_date
    FROM fileset
    WHERE sub_id = passed_id;

    SELECT count(sub_date) INTO count_dates
    FROM fileset
    WHERE sub_id = passed_id;

    -- The average interval is just the max_date minus the min_date divided
    -- by the number of intervals.
    SET avg_interval = (max_date - min_date) / (count_dates - 1);

    RETURN avg_interval;
END!

DELIMITER ;

-- TEST QUERIES
-- select sub_id, avg_submit_interval(sub_id) from fileset order by sub_id;
-- SELECT sub_id, min_submit_interval(sub_id) AS min_interval,
    -- max_submit_interval(sub_id) AS max_interval,
    -- avg_submit_interval(sub_id) AS avg_interval
-- FROM (SELECT sub_id FROM fileset
    -- GROUP BY sub_id HAVING COUNT(*) > 1) AS multi_subs
-- ORDER BY min_interval, max_interval LIMIT 20;

-- [Problem 4]
-- Create an index on sub_id because we call WHERE on sub_id often; thus,
-- indexing this makes it much faster to search for sub_id and thus makes these
-- WHEREs much faster
CREATE INDEX idx_id ON fileset(sub_id);
