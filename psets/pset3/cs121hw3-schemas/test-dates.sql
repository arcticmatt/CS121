-- A simple table for testing the user-defined date functions.
-- The table is loaded with a handful of test dates listed below.

DROP TABLE IF EXISTS test_dates;

CREATE TABLE test_dates (
  test_date DATE        PRIMARY KEY,
  weekend   BOOLEAN,
  holiday   VARCHAR(20)
);


-- Neither weekends nor holidays.
INSERT INTO test_dates VALUES ('2006-02-17', FALSE, NULL);
INSERT INTO test_dates VALUES ('2005-05-12', FALSE, NULL);
INSERT INTO test_dates VALUES ('2008-12-31', FALSE, NULL);
INSERT INTO test_dates VALUES ('2004-08-02', FALSE, NULL);
INSERT INTO test_dates VALUES ('2007-01-18', FALSE, NULL);

-- Weekends and not holidays.
INSERT INTO test_dates VALUES ('2010-08-14', TRUE, NULL);
INSERT INTO test_dates VALUES ('2006-06-11', TRUE, NULL);
INSERT INTO test_dates VALUES ('2002-01-06', TRUE, NULL);
INSERT INTO test_dates VALUES ('2003-07-05', TRUE, NULL);
INSERT INTO test_dates VALUES ('2002-12-15', TRUE, NULL);

-- Holidays and not weekends.
INSERT INTO test_dates VALUES ('2001-01-01', FALSE, 'New Year\'s Day');
INSERT INTO test_dates VALUES ('2001-11-22', FALSE, 'Thanksgiving');
INSERT INTO test_dates VALUES ('2002-07-04', FALSE, 'Independence Day');
INSERT INTO test_dates VALUES ('2002-09-02', FALSE, 'Labor Day');
INSERT INTO test_dates VALUES ('2005-05-30', FALSE, 'Memorial Day');
INSERT INTO test_dates VALUES ('2006-09-04', FALSE, 'Labor Day');
INSERT INTO test_dates VALUES ('2007-07-04', FALSE, 'Independence Day');
INSERT INTO test_dates VALUES ('2010-05-31', FALSE, 'Memorial Day');
INSERT INTO test_dates VALUES ('2010-11-25', FALSE, 'Thanksgiving');

-- Weekends and holidays.
INSERT INTO test_dates VALUES ('2000-01-01', TRUE, 'New Year\'s Day');
INSERT INTO test_dates VALUES ('2004-07-04', TRUE, 'Independence Day');
INSERT INTO test_dates VALUES ('2006-01-01', TRUE, 'New Year\'s Day');
INSERT INTO test_dates VALUES ('2010-07-04', TRUE, 'Independence Day');

