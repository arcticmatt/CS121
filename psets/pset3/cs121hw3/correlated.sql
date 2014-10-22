-- [Problem a]
-- The original clause. This clause is computing the number of loans each
-- customer has.
-- SELECT customer_name,
    -- (SELECT COUNT(*) FROM borrower b
    -- WHERE b.customer_name = c.customer_name) AS num_loans
-- FROM customer c ORDER BY num_loans DESC;
SELECT customer_name, COUNT(borrower.customer_name) AS num_loans
FROM customer NATURAL LEFT JOIN borrower
GROUP BY customer_name ORDER BY num_loans DESC;


-- [Problem b]
-- The original clause. This clause gives us the branches that have a
-- greater sum of loans than they do assets.
-- SELECT branch_name FROM branch b
-- WHERE assets < (SELECT SUM(amount) FROM loan l
                -- WHERE l.branch_name = b.branch_name);
SELECT branch_name
FROM branch AS b NATURAL JOIN
    (SELECT branch_name, SUM(amount) AS sum_loans
    FROM loan AS l
    GROUP BY branch_name) AS l
WHERE b.assets < l.sum_loans;


-- [Problem c]
SELECT branch_name,
    (SELECT COUNT(*)
    FROM account AS a
    WHERE a.branch_name = b.branch_name) AS num_accounts,
        (SELECT COUNT(*)
        FROM loan AS l
        WHERE l.branch_name = b.branch_name) AS num_loans
FROM branch AS b ORDER BY branch_name;

-- [Problem d]
SELECT branch_name, IFNULL(num_accounts, 0) AS num_accounts,
IFNULL(num_loans, 0) AS num_loans
FROM branch AS b NATURAL LEFT JOIN
    (SELECT branch_name, COUNT(account_number) AS num_accounts
    FROM account
    GROUP BY branch_name) AS a NATURAL LEFT JOIN
        (SELECT branch_name, COUNT(loan_number) AS num_loans
        FROM loan
        GROUP BY branch_name) AS l;
