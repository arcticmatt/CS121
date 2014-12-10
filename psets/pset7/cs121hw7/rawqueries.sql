-- [Problem 2a]
-- Get total number of rows.
SELECT COUNT(*) FROM raw_web_log;


-- [Problem 2b]
-- For each IP address in the log data, compute the total number of
-- requests from that IP address.
SELECT ip_addr, COUNT(*) AS num_requests
FROM raw_web_log
GROUP BY ip_addr
ORDER BY num_requests DESC
LIMIT 20;


-- [Problem 2c]
-- Computes, for each resource:
--     - The total number of requests for that resource.
--     - The total number of bytes served for that resource.
SELECT resource, COUNT(ip_addr) AS num_requests, SUM(bytes_sent) AS bytes_served
FROM raw_web_log
GROUP BY resource
ORDER BY bytes_served DESC
LIMIT 20;


-- [Problem 2d]
-- Computes these values for each visit:
--     - The total number of requests made during that visit.
--     - The starting time of the visit.
--     - The ending time of the visit.
SELECT visit_val, ip_addr, COUNT(ip_addr) AS num_requests,
MIN(logtime) AS start_time, MAX(logtime) AS end_time
FROM raw_web_log
GROUP BY visit_val
ORDER BY num_requests DESC
LIMIT 20;
