-- [Problem 1]
DROP PROCEDURE IF EXISTS sp_deposit;
DELIMITER !

-- COMMENT
CREATE PROCEDURE sp_deposit(
    IN sp_account_number VARCHAR(15),
    IN amount            NUMERIC(12,2),
    OUT status           INTEGER
)
BEGIN
    START TRANSACTION;

    UPDATE account
        SET balance = balance + amount
        WHERE account_number = sp_account_number;

    SET status = 0;
    IF amount < 0 THEN
        SET status = -1;
        ROLLBACK;
    ELSEIF ROW_COUNT() = 0 THEN
        SET status = -2;
    END IF;

    COMMIT;
END!

DELIMITER ;

-- Testing
-- SELECT * FROM account WHERE account_number='A-106';
-- CALL sp_deposit('A-106', 1000.10, @status);
-- CALL sp_deposit('ZB106', 10.00, @status);
-- SELECT @status;

-- [Problem 2]
DROP PROCEDURE IF EXISTS sp_withdraw;
DELIMITER !

-- COMMENT
CREATE PROCEDURE sp_withdraw(
    IN sp_account_number VARCHAR(15),
    IN amount            NUMERIC(12,2),
    OUT status           INTEGER
)
BEGIN
    DECLARE sp_balance NUMERIC(12,2) DEFAULT NULL;

    SET status = 0;
    IF amount < 0 THEN
        SET status = -1;
    ELSE
        START TRANSACTION;

        SELECT balance INTO sp_balance
        FROM account
        WHERE account_number = sp_account_number;

        -- If sp_balance is NULL, it will still be NULL after this SET
        SET sp_balance = sp_balance - amount;

        IF sp_balance IS NULL THEN
            SET status = -2;
        ELSEIF sp_balance < 0 THEN
            SET status = -3;
        ELSE
            UPDATE account
                SET balance = sp_balance
                WHERE account_number = sp_account_number;
        END IF;

        COMMIT;
    END IF;
END!

DELIMITER ;

-- Testing
-- SELECT * FROM account WHERE account_number='A-106';
-- CALL sp_withdraw('A-106', 2000.00, @status);
-- CALL sp_withdraw('ZB106', 10.00, @status);
-- SELECT @status;


-- [Problem 3]
DROP PROCEDURE IF EXISTS sp_transfer;
DELIMITER !

-- COMMENT
CREATE PROCEDURE sp_transfer(
    IN sp_account_1_number VARCHAR(15),
    IN amount              NUMERIC(12,2),
    IN sp_account_2_number VARCHAR(15),
    OUT status             INTEGER
)
BEGIN
    START TRANSACTION;

    COMMIT;
END!

DELIMITER ;
