-- [Problem 1]
-- DESCRIPTION: simple auto insurance database

-- Drop tables if they already exist so that they can get recreated.
-- Drop the referencing tables first to respect referential integrity.
-- Notice that we get warnings if we try to drop tables that don't exist.
DROP TABLE IF EXISTS participated;
DROP TABLE IF EXISTS owns;
DROP TABLE IF EXISTS person;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS accident;

-- This table contains people.
CREATE TABLE person (
    driver_id    CHAR(10),               -- Person ID
    name         VARCHAR(100) NOT NULL,  -- Person name
    address      VARCHAR(100) NOT NULL,  -- Person address
    PRIMARY KEY (driver_id)
);

-- This table contains cars.
CREATE TABLE car (
    license    CHAR(7),      -- Car license number
    model      VARCHAR(30),  -- Car model
    year       YEAR(4),      -- Year the car was made
    PRIMARY KEY (license)
);

-- This table contains accidents.
CREATE TABLE accident (
    report_number    INTEGER AUTO_INCREMENT, -- Auto-increment report numbers
    date_occurred    DATETIME NOT NULL,      -- Date of accident
    location         VARCHAR(1000) NOT NULL, -- Nearby address or intersection
    description      TEXT,                   -- Accident report
    PRIMARY KEY (report_number)
);

-- This table contains driver_id/license pairs, so basically people who
-- own a car.
-- This is a referencing table; references person and car.
CREATE TABLE owns (
    driver_id    CHAR(10), -- Driver ID
    license      CHAR(7),  -- License of car driver owns
    PRIMARY KEY (driver_id, license),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE
                                                         ON UPDATE CASCADE,
    FOREIGN KEY (license) REFERENCES car(license)        ON DELETE CASCADE
                                                         ON UPDATE CASCADE
);

-- This table contains cars that were involved in an accident.
-- This is a referencing table; references person, car, and accident.
CREATE TABLE participated (
    driver_id       CHAR(10), -- Driver ID of particpant
    license         CHAR(7),  -- Car license number
    report_number   INTEGER,  -- Updates cascade, so no need for auto-increment
    damage_amount   NUMERIC(9, 2), -- Use numeric to represent dollar amount
    PRIMARY KEY (driver_id, license, report_number),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON UPDATE CASCADE,
    FOREIGN KEY (license) REFERENCES car(license)        ON UPDATE CASCADE,
    FOREIGN KEY (report_number) REFERENCES accident(report_number)
                                                         ON UPDATE CASCADE
);
