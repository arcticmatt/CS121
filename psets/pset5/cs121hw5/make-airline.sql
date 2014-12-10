-- USING 1 LATE TOKEN

-- [Problem 5]

-- DROP TABLE commands:
-- Drop tables in order respecting foreign key constraints
DROP TABLE IF EXISTS itinerary;
DROP TABLE IF EXISTS ticket_seat;
DROP TABLE IF EXISTS ticket_traveler;
DROP TABLE IF EXISTS ticket_purchase;
DROP TABLE IF EXISTS txn;
DROP TABLE IF EXISTS customer_phone;
DROP TABLE IF EXISTS seat;
DROP TABLE IF EXISTS aircraft;
DROP TABLE IF EXISTS ticket_flight;
DROP TABLE IF EXISTS flight;
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS purchaser;
DROP TABLE IF EXISTS traveler;
DROP TABLE IF EXISTS purchase;
DROP TABLE IF EXISTS customer;


-- CREATE TABLE commands:
-- This table holds customers of the information and their general information.
-- More specific information about customers can be found in purchaser and
-- traveler.
CREATE TABLE customer (
    customer_id     INTEGER AUTO_INCREMENT,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_id)
);

-- This table holds purchases. A purchase is a collection of one or more
-- tickets bought by a particular purchaser in a single transaction.
-- Purchases and tickets are related via the ticket_purchase table.
-- One purchaser (found below) can make multiple purchases. Purchasers
-- and purchases are related via the txn table.
CREATE TABLE purchase (
    purchase_id           INTEGER AUTO_INCREMENT,
    purchase_date         TIMESTAMP NOT NULL,
    -- This is a number that the purchaser can use to access the purchase
    confirmation_number   CHAR(6) UNIQUE NOT NULL,
    PRIMARY KEY (purchase_id)
);

-- This table holds travelers, who are a type of customer. Travelers
-- do not have payment information. For international flights, travelers
-- must provide the details passport_number, citizenship_country,
-- emergency_name, and emergency_phone_number. However, they are not required
-- to provide these details immediately; they only need to be entered at least
-- 72 hours before the flight (thus why we allow null values for these
-- attributes). Each traveler will have one or more tickets associated with
-- them; these associations are represented via the ticket_traveler table.
CREATE TABLE traveler (
    customer_id              INTEGER,
    passport_number          VARCHAR(40) UNIQUE,
    citizenship_country      VARCHAR(50),
    emergency_name           VARCHAR(50), -- Name of emergency contact.
    emergency_phone_number   VARCHAR(15), -- Phone number of emergency contact
    -- Used for participants of the frequent-flyer program
    frequent_flyer_number    CHAR(7) UNIQUE,
    PRIMARY KEY (customer_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- This table holds purchasers, who are a type of customer. Purchasers
-- have optional payment information (credit_card_number, expiration_date,
-- verification_code). Purchasers can make purchases; this association is
-- represented by the txn table.
CREATE TABLE purchaser (
    customer_id              INTEGER,
    credit_card_number       CHAR(16),
    expiration_date          CHAR(5), -- Of the credit card.
    verification_code        CHAR(3), -- Of the credit card
    PRIMARY KEY (customer_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- This table holds tickets. Each ticket has a unique id (unique across
-- all tickets ever issued by the airline) and a price. Tickets are
-- related to purchases, travelers, flights, and seats via the tables
-- ticket_purchase, ticket_traveler, ticket_flight, and ticket_seat,
-- respectively.
CREATE TABLE ticket (
    ticket_id                INTEGER AUTO_INCREMENT,
    sale_price               NUMERIC(6, 2) NOT NULL,
    PRIMARY KEY (ticket_id)
);

-- This table holds flights and various information about flights.
CREATE TABLE flight (
    flight_number            VARCHAR(20),
    flight_date              DATE,
    flight_time              TIME NOT NULL,
    -- Source airport, represented by 3-letter IATA airport code
    source                   CHAR(3) NOT NULL,
    -- Destination airport, represented by 3-letter IATA airport code
    destination              CHAR(3) NOT NULL,
    -- Flag that tells if flight is within the country or between two countries
    is_domestic              BOOLEAN NOT NULL,
    -- Notice that the primary key is flight_number and flight_date; this is
    -- done because a given flight_number will be reused on different days,
    -- but the combination of flight_number and flight_date will be unique.
    PRIMARY KEY (flight_number, flight_date)
);

-- This table represents the relationship betwewen flights and tickets.
-- One flight can have many tickets, but one ticket only has one flight.
CREATE TABLE ticket_flight (
    ticket_id                INTEGER REFERENCES ticket(ticket_id)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    flight_number            VARCHAR(20) NOT NULL
                             REFERENCES flight(flight_number)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    flight_date              DATE NOT NULL
                             REFERENCES flight(flight_date)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    -- ticket_id is the primary key since we have a many-to-one mapping from
    -- ticket to flight
    PRIMARY KEY (ticket_id)
);

-- This table holds aircrafts, which are uniquely identified by type_code.
CREATE TABLE aircraft (
    -- 3-character value that the IATA uses to specify the kind of airplane
    -- a flight uses (unique for every kind of aircraft).
    type_code                CHAR(3),
    manufacturer             VARCHAR(40) NOT NULL,
    model                    VARCHAR(40) NOT NULL,
    PRIMARY KEY (type_code)
);

-- This table holds seats. Seats are related to tickets by the ticket_seat
-- table.
CREATE TABLE seat (
    type_code                CHAR(3),
    seat_number              VARCHAR(4),
    seat_class               VARCHAR(30) NOT NULL, -- First/second/business/etc
    seat_type                VARCHAR(30) NOT NULL,
    -- Flag specifying whether the seat is in an exit row
    is_exit                  BOOLEAN NOT NULL,
    -- We use type_code and seat_number as our primary key because each seat
    -- number will be unique on a specific kind of aircraft, but different kinds
    -- of aircraft will definitely have seats with overlapping seat numbers.
    PRIMARY KEY (type_code, seat_number),
    FOREIGN KEY (type_code) REFERENCES aircraft(type_code)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Holds customer phone numbers. We need a whole table for this since a customer
-- may have multiple phone numbers.
CREATE TABLE customer_phone (
    customer_id              INTEGER,
    phone_number             VARCHAR(15),
    -- A customer may have multiple phone numbers, hence the
    -- multi-column primary key
    PRIMARY KEY (customer_id, phone_number),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- This table holds transactions by customers (purchasers). This table relates
-- the purchaser and the purchase table. This is a one-to-many relationship.
CREATE TABLE txn (
    purchase_id              INTEGER,
    customer_id              INTEGER NOT NULL,
    -- Since the relationship is one-to-many between purchaser and purchase,
    -- purchase_id is our primary key.
    PRIMARY KEY (purchase_id),
    FOREIGN KEY (purchase_id) REFERENCES purchase(purchase_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- This table holds ticket purchases. This table relates the purchase and ticket
-- tables. This is a one-to-many relationship.
CREATE TABLE ticket_purchase (
    ticket_id                INTEGER,
    purchase_id              INTEGER NOT NULL,
    -- Since the relationship is one-to-many between purchase and ticket,
    -- ticket_id is our primary key.
    PRIMARY KEY (ticket_id),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (purchase_id) REFERENCES purchase(purchase_id)
        ON DELETE cascade
        ON UPDATE CASCADE
);

-- This table relates the ticket and traveler tables; that is, it lets us
-- know what tickets a certain traveler has. The traveler-ticket relationship
-- is a one-to-many relationship.
CREATE TABLE ticket_traveler (
    ticket_id               INTEGER,
    customer_id             INTEGER NOT NULL,
    PRIMARY KEY (ticket_id),
    -- Since our relationship is one-to-many between traveler and ticket,
    -- ticket_id is our primary key.
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- This table relates the seat and ticket tables. This is a one-to-one
-- relationship.
CREATE TABLE ticket_seat (
    ticket_id               INTEGER,
    seat_number             VARCHAR(4) NOT NULL REFERENCES seat(seat_number)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    PRIMARY KEY (ticket_id),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- This table relates the flight and aircraft tables. This is a many-to-one
-- relationship.
CREATE TABLE itinerary (
    flight_number           VARCHAR(20) REFERENCES flight(flight_number)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    flight_date             DATE REFERENCES flight(flight_date)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    type_code               CHAR(3) NOT NULL REFERENCES aircraft(type_code)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    -- Since this is a many-to-one relationship (between flight and aircraft),
    -- type_code alone cannot be our primary key. Thus we make it as so.
    PRIMARY KEY (flight_number, flight_date)
);
