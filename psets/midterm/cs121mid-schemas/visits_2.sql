TRUNCATE TABLE weblog;

# This test data contains 5 visits from different IP address, all at the same time.
INSERT INTO weblog (ip_addr, logtime, method, resource, protocol, response, bytes_sent)
VALUES ('10.20.30.40', '2012-01-01 09:15:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.30.40.50', '2012-01-01 09:15:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.30.50.60', '2012-01-01 09:15:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.40.50.60', '2012-01-01 09:15:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.40.60.80', '2012-01-01 09:15:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345);
