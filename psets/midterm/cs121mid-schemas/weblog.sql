DROP TABLE IF EXISTS weblog;

/* A simple database table to hold web logs. */
CREATE TABLE weblog (
  -- The IP address (or hostname) of the client requesting the resource.
  ip_addr       VARCHAR(100),

  -- The date and time of the request, in the server's local time.
  logtime       TIMESTAMP,

  -- The HTTP request method, typically one of GET, PUT, POST, WRITE,
  -- DELETE, etc.
  method        VARCHAR(15),

  -- The path to the specific resource or file being requested.
  resource      VARCHAR(200),

  -- The HTTP protocol version that is specified for the request.
  protocol      VARCHAR(200),

  -- The HTTP response code from the server, e.g. 200 for "OK",
  -- or 404 for "Not found".
  response      INTEGER,

  -- Total bytes sent to the client, for this request.
  bytes_sent    INTEGER
);
