-- PLEASE DO NOT INCLUDE date-udfs HERE!!!

-- [Problem 4a]
-- Here we want to insert all distinct combinations of values that appear
-- in the raw web logs (resource, method, protocol, response).
-- So to do this, we will just insert a select statement
-- in which we group by those values to make them distinct.
INSERT INTO resource_dim(resource, method, protocol, response)
    SELECT resource, method, protocol, response
    FROM raw_web_log
    GROUP BY resource, method, protocol, response;


-- [Problem 4b]
-- Here we want to insert all distinct combinations of values that appear
-- in the raw web logs (ip_addr, visit_val). So to do this, we will
-- just insert a select statement
-- in which we group by those values to make them distinct.
INSERT INTO visitor_dim(ip_addr, visit_val)
    SELECT ip_addr, visit_val
    FROM raw_web_log
    GROUP BY ip_addr, visit_val;


-- [Problem 4c]
-- IMPORTANT - REQUIRES UDFS from date-udfs.sql
-- Now we will write our stored procedure.
-- This stored procedure just goes through every date/hour combo in the
-- passed-in interval, and for each combo, finds out if that combo is
-- a weekend and/or holiday using the UDFS from date-udfs.sql. Then it
-- inserts all that info into the table.
DROP PROCEDURE IF EXISTS populate_dates;
DELIMITER !
CREATE PROCEDURE populate_dates(d_start DATE, d_end DATE) BEGIN
    DECLARE d DATE DEFAULT d_start; -- set default day to d_start
    DECLARE h INTEGER DEFAULT 0;

    DELETE FROM datetime_dim
    WHERE date_val BETWEEN d_start AND d_end;

    WHILE d <= d_end DO -- go through all days
        SET h = 0;
            WHILE h <= 23 DO -- go through all hours
                -- perform insert
                INSERT INTO datetime_dim(date_val, hour_val, weekend, holiday)
                    VALUES (d, h, is_weekend(d), is_holiday(d));
                SET h = h + 1;
            END WHILE;
        SET d = d + INTERVAL 1 DAY;
    END WHILE;

END!

DELIMITER ;
￼
-- CALL populate_dates('1995-07-01', '1995-08-31');

-- [Problem 5a]
-- Here we populate the resource_fact table. For this, we want to group
-- on date_id and resource_id, since we are computing aggregates over that
-- grouping. Then, we want to JOIN ON all the values that raw_web_log and
-- datetime_dim and resource_dim have in common to get all the neccessary
-- information. Notice that when we join, we use the <=> operator to equate
-- null values to null values. Finally, we just select our desired attributes
-- and aggregate functions and insert them into the table.
INSERT INTO resource_fact(date_id, resource_id, num_requests, total_bytes)
SELECT date_id, resource_id, COUNT(ip_addr) AS num_requests, SUM(bytes_sent)
    AS total_bytes
FROM raw_web_log AS rw JOIN datetime_dim AS d ON
    (DATE(rw.logtime) <=> d.date_val AND HOUR(rw.logtime) <=> d.hour_val)
    JOIN resource_dim AS r ON (rw.resource <=> r.resource
    AND rw.method <=> r.method AND rw.protocol <=> r.protocol
    AND rw.response <=> r.response)
GROUP BY date_id, resource_id;

-- Testing
-- SELECT date_id, COUNT(*) AS c FROM resource_fact
-- GROUP BY date_id ORDER BY c DESC LIMIT 3;


-- [Problem 5b]
-- Here we populate the visitor_fact table. For this, we want to group
-- on date_id and visitor_id, since we are computing aggregates over that
-- grouping. Then, we want to JOIN ON all the values that raw_web_log and
-- datetime_dim and visitor_dim have in common to get all the neccessary
-- information. Notice that when we join, we use the <=> operator to equate
-- null values to null values. Finally, we just select our desired attributes
-- and aggregate functions and insert them into the table.
INSERT INTO visitor_fact(date_id, visitor_id, num_requests, total_bytes)
SELECT date_id, visitor_id, COUNT(rw.ip_addr) AS num_requests, SUM(bytes_sent)
    AS total_bytes
FROM raw_web_log AS rw JOIN datetime_dim AS d ON
    (DATE(rw.logtime) <=> d.date_val AND HOUR(rw.logtime) <=> d.hour_val)
    JOIN visitor_dim AS v ON (rw.ip_addr <=> v.ip_addr
    AND rw.visit_val <=> v.visit_val)
GROUP BY date_id, visitor_id;

-- Testing
-- SELECT date_id, COUNT(*) AS c FROM visitor_fact
-- GROUP BY date_id ORDER BY c DESC LIMIT 3;
