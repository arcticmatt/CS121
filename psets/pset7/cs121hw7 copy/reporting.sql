-- [Problem 6a]
-- Here we write a query that reports each distinct HTTP protocol value,
-- along with the total number of requests using that protocol value.
SELECT protocol, SUM(num_requests) AS total_requests
FROM resource_dim NATURAL JOIN resource_fact
GROUP BY protocol
ORDER BY total_requests DESC
LIMIT 10;


-- [Problem 6b]
-- Here we write a query that reports the top 20 (resource, error response)
-- combinations.
SELECT resource, response, SUM(num_requests) AS num_errors
FROM resource_dim NATURAL JOIN resource_fact
WHERE response >= 400
GROUP BY resource, response
ORDER BY num_errors DESC
LIMIT 20;


-- [Problem 6c]
-- Here we write a query that finds the top 20 clients based on total bytes
-- sent to each client.
SELECT ip_addr, COUNT(DISTINCT visit_val) AS num_visits,
    SUM(num_requests) AS total_requests, SUM(total_bytes) AS total_bytes
FROM visitor_dim NATURAL JOIN visitor_fact
GROUP BY ip_addr
ORDER BY total_bytes DESC
LIMIT 20;


-- [Problem 6d]
-- Here we write a query that reports the daily request-total and the total
-- bytes served, for each day starting on July 23, 1995, and ending on August
-- 12, 1995.
-- The gap between 8/1 and 8/3 was caused by Hurricane Erin, which caused
-- the Web server to shut down.
-- The gap between 7/28 and 8/1 has no explanation.
SELECT date_val, IFNULL(SUM(num_requests), 0) AS daily_request_total,
    IFNULL(SUM(total_bytes), 0) AS total_bytes_served
FROM datetime_dim NATURAL LEFT JOIN resource_fact
WHERE date_val BETWEEN '1995-07-23' AND '1995-08-12'
GROUP BY date_val;


-- [Problem 6e]
-- Here we write a query that, for each day that appears in the data-set,
-- reports the resource that generated the largest "total bytes served"
-- for that day. We do this by joining together two tables and selecting on
-- that join. The first table we join on is a table that contains the maximum
-- value for "total bytes served" for each date_val. The second table we join
-- on is a table that contains the "total bytes served" value for each
-- date_val/resource combo. By joining these and selecting the rows where
-- total_bytes = max_total_bytes we get the desired query.
SELECT date_val, resource, total_requests, total_bytes
FROM
    (SELECT date_val, MAX(total_bytes) AS max_total_bytes
    FROM
        (SELECT date_val, SUM(total_bytes) AS total_bytes
        FROM datetime_dim NATURAL JOIN resource_fact NATURAL JOIN resource_dim
        GROUP BY date_val, resource) AS temp
    GROUP BY date_val) AS temp2 NATURAL JOIN
    (SELECT date_val, resource, SUM(num_requests) AS total_requests,
    SUM(total_bytes) AS total_bytes
    FROM datetime_dim NATURAL JOIN resource_fact NATURAL JOIN resource_dim
    GROUP BY date_val, resource) AS temp3
WHERE total_bytes = max_total_bytes
ORDER BY date_val;

-- [Problem 6f]
-- We can see that between the hours of 7 and 17, the average number of weekday
-- visits is a good deal larger than the average number of weekend visits (
-- greater by more than 100). A probable cause for this is that during the week,
-- people are at work doing their jobs. And many of these jobs probably require
-- people to access the internet and to visit internet resources, which drives
-- up the visit numbers during work hours (hours 7-17 fall within work hours).
-- On the weekends, people are not at work, they are at
-- home. And back then, most people did not have always-on and/or broadband
-- Internet access at home. So when people were at home, they were not able
-- to access the internet as much as if they were at work.
-- So basically the probable cause is that internet is more accessible at work
-- than at home.
SELECT hour_val, avg_weekday_visits, avg_weekend_visits
FROM
    (SELECT hour_val, COUNT(visit_val) /
        (SELECT COUNT(DISTINCT date_val)
        FROM datetime_dim AS d2 NATURAL JOIN visitor_fact
            NATURAL JOIN visitor_dim
        WHERE weekend = FALSE AND d2.hour_val = d1.hour_val)
            AS avg_weekday_visits
    FROM datetime_dim AS d1 NATURAL JOIN visitor_fact NATURAL JOIN visitor_dim
    WHERE weekend = FALSE
    GROUP BY hour_val) AS weekday_temp
    NATURAL JOIN
    (SELECT hour_val, COUNT(visit_val) /
        (SELECT COUNT(DISTINCT date_val)
        FROM datetime_dim AS d2 NATURAL JOIN visitor_fact
            NATURAL JOIN visitor_dim
        WHERE weekend = TRUE AND d2.hour_val = d1.hour_val)
            AS avg_weekend_visits
    FROM datetime_dim AS d1 NATURAL JOIN visitor_fact NATURAL JOIN visitor_dim
    WHERE weekend = True
    GROUP BY hour_val) AS weekend_temp;
