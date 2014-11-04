TRUNCATE TABLE weblog;

# This test data contains 5 visits from the same IP address, but each visit contains
# multiple accesses.
INSERT INTO weblog (ip_addr, logtime, method, resource, protocol, response, bytes_sent)
VALUES # Visit contains multiple accesses at "the same time" (at least as far as the
       # log resolution is concerned)
       ('10.20.30.40', '2012-01-01 09:15:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 09:15:00', 'GET', '/bar', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 09:25:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),

       # Visit's total length is larger than the gap between visits
       ('10.20.30.40', '2012-01-01 10:15:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 10:25:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 10:35:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 10:45:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 10:55:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),

       # Multiple accesses at "the same time" at the end of the visit
       ('10.20.30.40', '2012-01-01 12:15:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 12:16:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 12:17:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 12:18:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 12:18:00', 'GET', '/bar', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 12:18:00', 'GET', '/abc', 'HTTP/1.0', 200, 12345),

       # This is *exactly* the time interval from the previous visit that should
       # be considered a new visit
       ('10.20.30.40', '2012-01-01 12:48:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),

       # Five requests all "at the same time"
       ('10.20.30.40', '2012-01-01 13:18:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 13:18:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 13:18:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 13:18:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345),
       ('10.20.30.40', '2012-01-01 13:18:00', 'GET', '/foo', 'HTTP/1.0', 200, 12345);
