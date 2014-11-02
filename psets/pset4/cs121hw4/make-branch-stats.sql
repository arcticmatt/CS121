-- [Problem 1]
-- Create index on branch_name because branch_name is used in a bunch of WHERE
-- statements
CREATE INDEX idx_branch_name ON account(branch_name);


-- [Problem 2]
-- This table mimics a materialized view, and contains statistics for
-- branches.
CREATE TABLE mv_branch_account_stats (
    branch_name    VARCHAR(15),
    num_accounts   INTEGER NOT NULL DEFAULT 0,
    total_deposits INTEGER NOT NULL DEFAULT 0,
    min_balance    NUMERIC(12, 2) NOT NULL DEFAULT 0,
    max_balance    NUMERIC(12, 2) NOT NULL DEFAULT 0,
    PRIMARY KEY (branch_name)
);


-- [Problem 3]
-- Populate the table with values from the account table.
INSERT INTO mv_branch_account_stats
    SELECT branch_name,
        COUNT(*) AS num_accounts,
        SUM(balance) AS total_deposits,
        MIN(balance) AS min_balance,
        MAX(balance) AS max_balance
    FROM account GROUP BY branch_name;


-- [Problem 4]
-- Create a view on mv_branch_account_stats. This view includes avg_balance,
-- which is calculated as a derived attribute for efficiency.
CREATE VIEW branch_account_stats AS
    SELECT branch_name,
        num_accounts,
        total_deposits,
        (total_deposits / num_accounts) AS avg_balance,
        min_balance,
        max_balance
    FROM mv_branch_account_stats GROUP BY branch_name;


-- [Problem 5]
DELIMITER !

-- Stored procedure for updating mv_branch_account_stats on an insert into
-- account. Used in trg_insert and trg_update.
CREATE PROCEDURE sp_insert(
    IN sp_branch_name VARCHAR(15),
    IN sp_balance NUMERIC(12, 2)
)
BEGIN
    IF sp_branch_name IN (SELECT branch_name FROM mv_branch_account_stats)
    THEN
        -- If not the first account for a particular branch, update the branch
        UPDATE mv_branch_account_stats
            SET num_accounts = num_accounts + 1,
                total_deposits = total_deposits + sp_balance,
                min_balance = LEAST(min_balance, sp_balance),
                max_balance = GREATEST(max_balance, sp_balance)
            WHERE branch_name = sp_branch_name;
    ELSE
        -- Else, insert the sumary info for the new branch
        INSERT INTO mv_branch_account_stats
            VALUES (sp_branch_name, 1, sp_balance, sp_balance, sp_balance);
    END IF;
END!

DELIMITER ;

DELIMITER !

-- Insert trigger on account that updates mv_branch_account_stats accordingly.
CREATE TRIGGER trg_insert AFTER INSERT ON account FOR EACH ROW
BEGIN
    CALL sp_insert(NEW.branch_name, NEW.balance);
END!

DELIMITER ;


-- [Problem 6]
DELIMITER !

-- Stored procedure for updating mv_branch_account_stats on a delete from
-- account. Used in trg_delete and trg_update.
CREATE PROCEDURE sp_delete(
    IN sp_branch_name VARCHAR(15),
    IN sp_balance NUMERIC(12, 2)
)
BEGIN
    IF 1 IN (SELECT num_accounts FROM mv_branch_account_stats WHERE
    branch_name = sp_branch_name) THEN
        -- If the deleted account is the last account for the branch, delete
        -- the branch from mv_branch_account_stats.
        DELETE FROM mv_branch_account_stats WHERE branch_name = sp_branch_name;
    ELSE
        -- Else, update the branch.
        UPDATE mv_branch_account_stats
            SET num_accounts = num_accounts - 1,
                total_deposits = total_deposits - sp_balance,
                min_balance = (SELECT MIN(balance) FROM account WHERE
                    branch_name = sp_branch_name),
                max_balance = (SELECT MAX(balance) FROM account WHERE
                    branch_name = sp_branch_name)
            WHERE branch_name = sp_branch_name;
    END IF;
END!

DELIMITER ;

DELIMITER !

-- Delete trigger on account that updates mv_branch_account_stats accordingly.
CREATE TRIGGER trg_delete AFTER DELETE ON account FOR EACH ROW
BEGIN
    CALL sp_delete(OLD.branch_name, OLD.balance);
END!

DELIMITER ;


-- [Problem 7]
DELIMITER !

-- Update trigger on account that updates mv_branch_account_stats accordingly.
CREATE TRIGGER trg_update AFTER UPDATE ON account FOR EACH ROW
BEGIN
    IF OLD.branch_name = NEW.branch_name THEN
        -- If the branch name did not change, update the summary info
        UPDATE mv_branch_account_stats
            SET total_deposits = total_deposits - OLD.balance + NEW.balance,
                min_balance = (SELECT MIN(balance) FROM account WHERE
                    branch_name = OLD.branch_name),
                max_balance = (SELECT MAX(balance) FROM account WHERE
                    branch_name = OLD.branch_name)
            WHERE branch_name = OLD.branch_name;
    ELSE
        -- Else, delete the old account from the old branch and add the new
        -- account to the new branch
        CALL sp_delete(OLD.branch_name, OLD.balance);
        CALL sp_insert(NEW.branch_name, NEW.balance);
    END IF;
END!

DELIMITER ;
