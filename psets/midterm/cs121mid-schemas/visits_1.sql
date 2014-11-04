TRUNCATE TABLE weblog;

# This test data contains 5 visits from the same IP address.  Nothing complicated.
INSERT INTO weblog (ip_addr, logtime, method, resource, protocol, response, bytes_sent)
VALUES ('10.20.30.40', '2012-01-01 09:15:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 10:15:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 11:15:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 12:15:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 13:15:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345);
