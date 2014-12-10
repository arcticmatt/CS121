-- [Problem 3]
-- Drop tables in order preserving foreign key constraints.
DROP TABLE IF EXISTS visitor_fact;
DROP TABLE IF EXISTS resource_fact;
DROP TABLE IF EXISTS visitor_dim;
DROP TABLE IF EXISTS resource_dim;
DROP TABLE IF EXISTS datetime_dim;

-- This is the dimension table for datetime. It contains datetime information
-- for some range of time. Every day/hour combination is represented as a
-- unique row in the table. Some time intervals may not correspond to any raw
-- data.
CREATE TABLE datetime_dim (
    date_id  INTEGER AUTO_INCREMENT,
    date_val DATE NOT NULL,
    hour_val INTEGER NOT NULL,
    weekend  BOOLEAN NOT NULL,
    holiday  VARCHAR(20),
    PRIMARY KEY (date_id),
    UNIQUE (date_val, hour_val)
);

-- This is the dimension table for resources. It contains internet resources,
-- and key information about those resources.
CREATE TABLE resource_dim (
    resource_id INTEGER AUTO_INCREMENT, -- unique id that identifies each
                                        -- resource
    resource    VARCHAR(200) NOT NULL,  -- resource name
    method      VARCHAR(15),            -- GET/POST
    protocol    VARCHAR(200),           -- internet protocol
    response    INTEGER NOT NULL,       -- number that describes response
    PRIMARY KEY (resource_id),
    UNIQUE (resource, method, protocol, response)
);

-- This is the dimension table for visitors. It contains internet visitors,
-- and key information about those visitors.
CREATE TABLE visitor_dim (
    visitor_id INTEGER AUTO_INCREMENT,
    ip_addr    VARCHAR(200) NOT NULL,
    visit_val  INTEGER NOT NULL,        -- indicates which visit this visitor
                                        -- took part in. in other words, diff
                                        -- visit vals -> diff visits
    PRIMARY KEY (visitor_id),
    UNIQUE (visit_val)
);

-- This is the fact table for resources. It contains internet resources
-- and their additional information (not the information stored in
-- resource_dim, besides resource_id).
CREATE TABLE resource_fact (
    date_id      INTEGER,
    resource_id  INTEGER,
    num_requests INTEGER NOT NULL, -- number of requests involving a resource
    total_bytes  BIGINT,           -- sum of the number of bytes sent to a
                                   -- resource
    PRIMARY KEY (date_id, resource_id),
    FOREIGN KEY (date_id) REFERENCES datetime_dim(date_id),
    FOREIGN KEY (resource_id) REFERENCES resource_dim(resource_id)
);

-- This is the fact table for resources. It contains visitors and their
-- additional information (not the information stored in visitor_dim, besides
-- visitor_id).
CREATE TABLE visitor_fact (
    date_id INTEGER,
    visitor_id INTEGER,
    num_requests INTEGER NOT NULL, -- number of requests involving a visitor
    total_bytes INTEGER,           -- sum of the number of bytes sent by visits
                                   -- made by a visitor
    PRIMARY KEY (date_id, visitor_id),
    FOREIGN KEY (date_id) REFERENCES datetime_dim(date_id),
    FOREIGN KEY (visitor_id) REFERENCES visitor_dim(visitor_id)
);
