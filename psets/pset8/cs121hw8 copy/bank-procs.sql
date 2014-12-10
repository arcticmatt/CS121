-- [Problem 1]
DROP PROCEDURE IF EXISTS sp_deposit;
DELIMITER !

-- This procedure deposits amount into the specified account. Specifically,
-- the procedure adds the amount to the current account balance. This procedure
-- sets the passed in OUT status variable to a certain value, depending on
-- how the operation goes.
--     0 indicates the operation was completed successfully
--     -1 indicates the specified amount is negative
--     -2 indicates the account number was invalid
-- Notice that if status is not set to 0, the operation was NOT completed
-- successfully.
CREATE PROCEDURE sp_deposit(
    IN sp_account_number VARCHAR(15),
    IN amount            NUMERIC(12,2),
    OUT status           INTEGER
)
BEGIN
    -- Begin by setting the status to 0
    SET status = 0;
    -- Check for negative amount
    IF amount < 0 THEN
        SET status = -1;
    ELSE
        -- If positive amount, start transaction
        START TRANSACTION;
            -- Update account, regardless of sp_account_number
            UPDATE account
                SET balance = balance + amount
                WHERE account_number = sp_account_number;

            -- Check if update actually changed anything. If not, then
            -- sp_account_number is not valid
            IF ROW_COUNT() = 0 THEN
                SET status = -2;
            END IF;
        COMMIT;
    END IF;
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

-- This procedure withdraws amount from the specified account. Specifically,
-- the procedure subtracts the amount from the current account balance. This
-- procedure sets the passed in OUT status variable to a certain value,
-- depending on how the operation goes.
--     0 indicates the operation was completed successfully
--     -1 indicates the specified amount is negative
--     -2 indicates the account number was invalid
--     -3 indicates the account being deducted from had insufficient funds.
--        No account balance may go below 0.
-- Notice that if status is not set to 0, the operation was NOT completed
-- successfully.
CREATE PROCEDURE sp_withdraw(
    IN sp_account_number VARCHAR(15),
    IN amount            NUMERIC(12,2),
    OUT status           INTEGER
)
BEGIN
    DECLARE sp_balance NUMERIC(12,2) DEFAULT NULL;

    -- Begin by setting the status to 0
    SET status = 0;
    -- Check for negative amount
    IF amount < 0 THEN
        SET status = -1;
    ELSE
        -- If positive amount, start transaction
        START TRANSACTION;
            -- Get the balance of the account before we update. Make sure that
            -- it doesn't become out of date with FOR UPDATE
            SELECT balance INTO sp_balance
            FROM account
            WHERE account_number = sp_account_number
            FOR UPDATE;

            -- Update the account, subtracting amount from the current balance
            UPDATE account
                SET balance = balance - amount
                WHERE account_number = sp_account_number;

            IF ROW_COUNT() = 0 THEN
                -- Check if update actually changed anything. If not, then
                -- sp_account_number is not valid
                SET status = -2;
            ELSEIF sp_balance < amount THEN
                -- Check if the account being deducted from has insufficient
                -- funds. If true, then ROLLBACK the UPDATE since it was
                -- invalid
                SET status = -3;
                ROLLBACK;
            END IF;
        COMMIT;
    END IF;
END!

DELIMITER ;

-- Testing
-- SELECT * FROM account WHERE account_number='A-106';
-- CALL sp_withdraw('A-106', -2000.00, @status);
-- CALL sp_withdraw('ZB106', 10.00, @status);
-- SELECT @status;


-- [Problem 3]
DROP PROCEDURE IF EXISTS sp_transfer;
DELIMITER !

-- This procedure transfers amount from sp_account_1_number to
-- sp_account_2_number. Specifically, the procedure subtracts the amount from
-- sp_account_1_number's balance and adds the amount to sp_account_2_number's
-- balance.
-- This procedure sets the passed in OUT status variable to a certain value,
-- depending on how the operation goes.
--     0 indicates the operation was completed successfully
--     -1 indicates the specified amount is negative
--     -2 indicates one of the account numbers was invalid
--     -3 indicates the account being deducted from had insufficient funds.
--        No account balance may go below 0.
-- Notice that if status is not set to 0, the operation was NOT completed
-- successfully.
CREATE PROCEDURE sp_transfer(
    IN sp_account_1_number VARCHAR(15),
    IN amount              NUMERIC(12,2),
    IN sp_account_2_number VARCHAR(15),
    OUT status             INTEGER
)
BEGIN
    DECLARE sp_balance NUMERIC(12,2) DEFAULT NULL;

    -- Begin by setting the status to 0
    SET status = 0;
    -- Check for negative amount
    IF amount < 0 THEN
        SET status = -1;
    ELSE
        -- If positive amount, start transaction
        START TRANSACTION;
            -- ==== PERFORM WITHDRAWAL ====
            -- Get the balance of the account before we update. Make sure that
            -- it doesn't become out of date with FOR UPDATE
            SELECT balance INTO sp_balance
            FROM account
            WHERE account_number = sp_account_1_number
            FOR UPDATE;

            -- Update the account, subtracting amount from the current balance
            UPDATE account
                SET balance = balance - amount
                WHERE account_number = sp_account_1_number;

            IF ROW_COUNT() = 0 THEN
                -- Check if update actually changed anything. If not, then
                -- sp_account_number is not valid
                SET status = -2;
            ELSEIF sp_balance < amount THEN
                -- Check if the account being deducted from has insufficient
                -- funds. If true, then ROLLBACK the UPDATE since it was
                -- invalid
                SET status = -3;
                ROLLBACK;
            ELSE
                -- ==== PERFORM DEPOSIT ====
                -- Update account, regardless of sp_account_number
                UPDATE account
                    SET balance = balance + amount
                    WHERE account_number = sp_account_2_number;

                -- Check if update actually changed anything. If not, then
                -- sp_account_number is not valid
                IF ROW_COUNT() = 0 THEN
                    SET status = -2;
                    ROLLBACK; -- Rollback the withdrawal
                END IF;
            END IF;
        COMMIT;
    END IF;
END!

DELIMITER ;

-- Testing
-- SELECT * FROM account WHERE account_number='A-106' OR account_number='A-123';
-- CALL sp_transfer('A-106', -200.00, 'Z-123', @status);
-- CALL sp_transfer('A-106', 10.00, 'A-123', @status);
-- SELECT @status;
