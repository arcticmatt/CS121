-- [Problem 1]
-- Get distinct address/time combos
CREATE VIEW addr_and_time AS
    SELECT DISTINCT ip_addr, logtime FROM weblog;

-- Get logtimes that are less than 30 minutes apart for the same ip address
CREATE VIEW small_intervals AS
    SELECT a.ip_addr, a.logtime AS a_logtime, b.logtime AS b_logtime,
    (UNIX_TIMESTAMP(b.logtime) - UNIX_TIMESTAMP(a.logtime)) AS time_diff
    FROM addr_and_time AS a JOIN addr_and_time AS b
    WHERE b.logtime > a.logtime AND b.logtime < a.logtime + INTERVAL 30 MINUTE
          AND a.ip_addr = b.ip_addr
    ORDER BY a.logtime, b.logtime;


-- Count all the intervals that were greater than or equal to 30 minutes (for
-- each individual ip_addr) and then add the count of distinct ip_addr
CREATE INDEX idx ON weblog(ip_addr);
SELECT COUNT(*) + (SELECT COUNT(DISTINCT ip_addr) FROM weblog) AS num_visits
FROM
    -- Here we group by ip_addr and a_logtime to get rid of the (possibly)
    -- many b_logtimes that may be more than 1800 seconds greater than
    -- a_logtime (since only one matters)
    (SELECT ip_addr, a_logtime, MIN(b_logtime) AS min_b_logtime
    FROM
        -- Here we select only the logtimes that are not in small_intervals;
        -- this means these log times were never part of an interval that
        -- was less than 30 minutes. Notice that the difference in logtimes
        -- is greater than or equal to 1800, which makes these intervals
        -- valid visits
        (SELECT a.ip_addr, a.logtime AS a_logtime, b.logtime AS b_logtime,
        (UNIX_TIMESTAMP(b.logtime) - UNIX_TIMESTAMP(a.logtime)) AS time_diff
        FROM addr_and_time AS a JOIN addr_and_time AS b
        WHERE (UNIX_TIMESTAMP(b.logtime) - UNIX_TIMESTAMP(a.logtime)) >= 1800
              AND a.logtime NOT IN (SELECT a_logtime
                                   FROM small_intervals)
              AND b.logtime NOT IN (SELECT b_logtime
                                   FROM small_intervals)
              AND a.ip_addr = b.ip_addr
        ORDER BY a.logtime, b.logtime) AS temp
    GROUP BY ip_addr, a_logtime) AS temp2;


-- [Problem 2]
-- My query doesn't run very slowly...
-- I guess one way to improve it would be to create an index. But I tried
-- that and it didn't work. So idk.


-- [Problem 3]
DROP FUNCTION IF EXISTS num_visits;

DELIMITER !

CREATE FUNCTION num_visits() RETURNS INTEGER
BEGIN
    DECLARE prev_log_time INTEGER;
    DECLARE curr_log_time INTEGER;
    DECLARE prev_ip_addr VARCHAR(100);
    DECLARE curr_ip_addr VARCHAR(100);
    DECLARE diff INTEGER;
    DECLARE num_visits INTEGER DEFAULT 0;

    DECLARE done INT DEFAULT 0;
    DECLARE cur CURSOR FOR
        SELECT ip_addr, UNIX_TIMESTAMP(logtime) AS logtime
        FROM weblog
        ORDER BY ip_addr, logtime;
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
        SET done = 1;

    OPEN cur;
    FETCH cur INTO prev_ip_addr, prev_log_time;
    IF NOT done THEN
        SET num_visits = 1;
    END IF;
    WHILE NOT done DO
        FETCH cur INTO curr_ip_addr, curr_log_time;
        IF NOT done THEN
            IF curr_ip_addr = prev_ip_addr THEN
                SET diff = curr_log_time - prev_log_time;
                IF diff >= 1800 THEN
                    SET num_visits = num_visits + 1;
                END IF;
            ELSE
                SET num_visits = num_visits + 1;
            END IF;
            SET prev_ip_addr = curr_ip_addr;
            SET prev_log_time = curr_log_time;
        END IF;
    END WHILE;
    CLOSE cur;
    RETURN num_visits;
END !

DELIMITER ;

SELECT num_visits();
