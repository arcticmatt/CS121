DROP FUNCTION IF EXISTS is_weekend;
DROP FUNCTION IF EXISTS is_holiday;


-- Set the "end of statement" character to ! so that semicolons in the
-- function body won't confuse MySQL.
DELIMITER !


CREATE FUNCTION is_weekend(d DATE) RETURNS BOOLEAN
BEGIN
  DECLARE day_of_week INTEGER;

  SET day_of_week = DAYOFWEEK(d);

  IF day_of_week = 1 OR day_of_week = 7 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

END !


CREATE FUNCTION is_holiday(d DATE) RETURNS VARCHAR(20)
BEGIN
  -- A string describing the holiday, or NULL if the
  -- specified date doesn't fall on a holiday.
  DECLARE result VARCHAR(20) DEFAULT NULL;

  DECLARE month_val, day_of_week, day_of_month INTEGER;

  -- January = 1, February = 2, etc.
  SET month_val    = MONTH(d);

  -- Sunday = 1, Monday = 2, etc.
  SET day_of_week  = DAYOFWEEK(d);

  SET day_of_month = DAYOFMONTH(d);

  -- Figure out which holiday the specified date falls on, if any.
  IF month_val = 1 AND day_of_month = 1 THEN
    -- New Year's Day always falls on January 1.
    SET result = 'New Year\'s Day';

  ELSEIF month_val = 5 AND day_of_week = 2 AND
          day_of_month BETWEEN 25 AND 31 THEN
    -- Memorial Day falls on the last Monday of May.
    SET result = 'Memorial Day';

  ELSEIF month_val = 7 AND day_of_month = 4 THEN
    -- Independence Day always falls on July 4.
    SET result = 'Independence Day';

  ELSEIF month_val = 9 AND day_of_week = 2 AND
          day_of_month BETWEEN 1 AND 7 THEN
    -- Labor Day falls on the first Monday of September.
    SET result = 'Labor Day';

  ELSEIF month_val = 11 AND day_of_week = 5 AND
          day_of_month BETWEEN 22 AND 28 THEN
    -- Thanksgiving Day falls on the fourth Thursday of November.
    SET result = 'Thanksgiving';

  END IF;

  -- All done.
  RETURN result;
END !


-- Back to the standard SQL delimiter
DELIMITER ;
