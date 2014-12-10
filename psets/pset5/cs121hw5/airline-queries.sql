-- USING 1 LATE TOKEN

-- [Problem 6a]
-- Here we select purchase_date and flight_date from the purchase history of
-- customer 54321, as well as the traveler last name and first name (the
-- traveler names are done with correlated subqueries).
SELECT purchase_date, flight_date,
    (SELECT last_name
    FROM traveler AS t1
    WHERE t1.customer_id IN (SELECT c FROM

    ((customer NATURAL JOIN txn NATURAL JOIN purchase NATURAL JOIN
    ticket_purchase NATURAL JOIN ticket NATURAL JOIN ticket_flight) NATURAL JOIN
    (SELECT ticket_id AS t, customer_id AS c
    FROM ticket_traveler) AS temp)

    )) AS last_name,
    (SELECT first_name
    FROM traveler AS t1
    WHERE t1.customer_id IN (SELECT c FROM

    ((customer NATURAL JOIN txn NATURAL JOIN purchase NATURAL JOIN
    ticket_purchase NATURAL JOIN ticket NATURAL JOIN ticket_flight) NATURAL JOIN
    (SELECT ticket_id AS t, customer_id AS c
    FROM ticket_traveler) AS temp)

    )) AS first_name
FROM
((customer NATURAL JOIN txn NATURAL JOIN purchase NATURAL JOIN ticket_purchase
NATURAL JOIN ticket NATURAL JOIN ticket_flight) NATURAL JOIN
    (SELECT ticket_id AS t, customer_id AS c
    FROM ticket_traveler) AS temp)
WHERE customer_id=54321
ORDER BY purchase_date DESC, flight_date ASC, last_name ASC, first_name ASC;


-- [Problem 6b]
-- This query first selects the type code and the sum of the ticket sales,
-- where everything is grouped by type_code. This query is limited to
-- flight_dates within the last two weeks. Then we do a natural left outer
-- join with aircraft and the table that query creates to include all airplanes.
SELECT type_code, IFNULL(sum_sales, 0) AS sum_sales
FROM aircraft NATURAL LEFT OUTER JOIN
    (SELECT type_code, SUM(sale_price) AS sum_sales
    FROM itinerary NATURAL JOIN flight NATURAL JOIN ticket_flight
    NATURAL JOIN ticket
    WHERE flight_date BETWEEN NOW() - INTERVAL 2 WEEK AND NOW()
    GROUP BY type_code) AS temp;


-- [Problem 6c]
-- Here we just select the customer_ids that are on international flights
-- and have not filled out all of their international flight info.
SELECT customer_id
FROM traveler NATURAL JOIN ticket_traveler NATURAL JOIN ticket NATURAL JOIN
    ticket_flight NATURAL JOIN flight
WHERE NOT is_domestic AND (passport_number IS NULL OR
    citizenship_country IS NULL OR emergency_name IS NULL OR
    emergency_phone_number IS NULL);
