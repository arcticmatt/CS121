-- [Problem 1]
DROP TABLE IF EXISTS participated;
DROP TABLE IF EXISTS owns;
DROP TABLE IF EXISTS person;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS accident;

CREATE TABLE person (
    driver_id    CHAR(10),
    name         VARCHAR(100) NOT NULL,
    address      VARCHAR(100) NOT NULL,
    PRIMARY KEY (driver_id)
);

CREATE TABLE car (
    license    CHAR(7),
    model      VARCHAR(30),
    year       YEAR(4),
    PRIMARY KEY (license)
);

CREATE TABLE accident (
    report_number    INTEGER AUTO_INCREMENT,
    date_occurred    DATETIME NOT NULL,
    location         VARCHAR(1000) NOT NULL,
    description      TEXT,
    PRIMARY KEY (report_number)
);

-- Referencing table
CREATE TABLE owns (
    driver_id    CHAR(10),
    license      CHAR(7),
    PRIMARY KEY (driver_id, license),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE
                                                         ON UPDATE CASCADE,
    FOREIGN KEY (license) REFERENCES car(license)        ON DELETE CASCADE
                                                         ON UPDATE CASCADE
);

-- Referencing table
CREATE TABLE participated (
    driver_id       CHAR(10),
    license         CHAR(7),
    report_number   INTEGER,
    damage_amount   NUMERIC(9, 2),
    PRIMARY KEY (driver_id, license, report_number),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON UPDATE CASCADE,
    FOREIGN KEY (license) REFERENCES car(license)        ON UPDATE CASCADE,
    FOREIGN KEY (report_number) REFERENCES accident(report_number)
                                                         ON UPDATE CASCADE
);
