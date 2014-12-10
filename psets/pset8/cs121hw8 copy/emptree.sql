-- [Problem 1]
-- Create a "temporary" table that contains emp_id's and salaries. We use this
-- table to store all the currently found employees that are in the subtree that
-- we are working with. That is, this table gets continually updated with
-- employees from a certain subtree of the hierarchy (until we have found
-- the entire subtree).
DROP TABLE IF EXISTS emp_tree;
CREATE TABLE emp_tree (
    emp_id     INTEGER PRIMARY KEY,
    salary INTEGER
);

DROP FUNCTION IF EXISTS total_salaries_adjlist;
DELIMITER !
-- This function uses employee_adjlist to compute the sum of all employee
-- salaries in a particular subtree of the hierarchy. The specified
-- employee's salary is also included.
CREATE FUNCTION total_salaries_adjlist(
    fn_emp_id INTEGER
) RETURNS INTEGER BEGIN
    DECLARE sum INTEGER DEFAULT 0;

    -- Clear our "temporary" table
    DELETE FROM emp_tree;

    -- We begin by inserting the specified employee and his/her salary into
    -- the emp_tree
    INSERT INTO emp_tree
        SELECT emp_id, salary
        FROM employee_adjlist
        WHERE emp_id = fn_emp_id;

    -- Then, while emp_tree is being updated, we will insert employees and their
    -- salaries from employee_adjlist if their manager is in emp_tree and
    -- they are not already contained in emp_tree. This basically gets the
    -- subtree one level at a time. First, we started out with the root. Then,
    -- we get employees that he manages. Then, we get all the employees that
    -- the employees in emp_tree manage, until we have them all.
    WHILE ROW_COUNT() > 0 DO
        INSERT INTO emp_tree SELECT emp_id, salary FROM employee_adjlist
            WHERE manager_id IN (SELECT emp_id FROM emp_tree)
            AND emp_id NOT IN (SELECT emp_id FROM emp_tree);
    END WHILE;
    SELECT SUM(salary) INTO sum FROM emp_tree;
    RETURN sum;
END!
DELIMITER ;

-- Testing
-- SELECT total_salaries_adjlist(100001);

-- [Problem 2]
DROP FUNCTION IF EXISTS total_salaries_nestset;
DELIMITER !
-- This function uses employee_nestset to compute the sum of all employee
-- salaries in a particular subtree of the hierarchy. The specified employee's
-- salary is also included.
CREATE FUNCTION total_salaries_nestset(
    fn_emp_id INTEGER
) RETURNS INTEGER BEGIN
    DECLARE sum INTEGER DEFAULT 0;
    DECLARE emp_low INTEGER;
    DECLARE emp_high INTEGER;

    -- First we select the low attribute of the specified employee into
    -- a declared variable
    SELECT low INTO emp_low
    FROM employee_nestset
    WHERE emp_id = fn_emp_id;

    -- Next we select the high attribute of the specified employee into
    -- a declared variable
    SELECT high INTO emp_high
    FROM employee_nestset
    WHERE emp_id = fn_emp_id;

    -- Finally, we sum the salaries of all the employees who have a low
    -- attribute between the declared low and high variables (emp_low and
    -- emp_high, the low and high attributes of the specified employee).
    -- By the design of the nested set model, this serves to sum the salaries
    -- of all the employees in the subtree, and since BETWEEN is inclusive, it
    -- also includes the specified employee's salary.
    SELECT SUM(salary) INTO sum
    FROM employee_nestset
    WHERE low BETWEEN emp_low AND emp_high;

    RETURN sum;
END!
DELIMITER ;

-- Testing
-- SELECT total_salaries_nestset(100001);
-- SELECT total_salaries_nestset(100391);

-- [Problem 3]
-- We want employees who manage no one. To do this, we can use a correlated
-- subquery, selecting all the employees who do not appear in the table of
-- managers. It is key that we exclude NULLs in the table of managers; if we
-- do not, the NULL values will mess up the NOT IN comparison and we will
-- get the empty set.
SELECT emp_id, name, salary
FROM employee_adjlist
WHERE emp_id NOT IN (SELECT manager_id FROM employee_adjlist
                    WHERE manager_id IS NOT NULL);


-- [Problem 4]
-- We want employees who manage no one. To do this, we can select employees
-- that contain no other employee's range values. To implement this idea,
-- we use NOT EXIST. Basically, for each employee e, we try selecting all
-- the employees that have a range low-high contained in e's range low-high.
-- If no such employees exist, we know e is a leaf.
SELECT emp_id, name, salary
FROM employee_nestset AS a
WHERE NOT EXISTS (
    SELECT low, high
    FROM employee_nestset AS b
    WHERE b.low > a.low AND b.high < a.high);


-- [Problem 5]
-- Create a "temporary" table that contains emp_id's. We use this
-- table to store all the currently found employees that are in the tree.
-- That is, this table gets continually updated with employees from the tree
-- of the hierarchy (until we have found the entire tree).
DROP TABLE IF EXISTS emp_tree_2;
CREATE TABLE emp_tree_2 (
    emp_id     INTEGER PRIMARY KEY
);

DROP FUNCTION IF EXISTS tree_depth;
DELIMITER !
CREATE FUNCTION tree_depth() RETURNS INTEGER BEGIN
    -- If inserting the root doesn't change anything, then the height will
    -- just be 0
    DECLARE height INTEGER DEFAULT 0;

    -- Clear our "temporary" table
    DELETE FROM emp_tree_2;

    -- Insert the root of the tree into emp_tree_2
    INSERT INTO emp_tree_2
        SELECT emp_id
        FROM employee_adjlist
        WHERE manager_id IS NULL;

    -- Then, while emp_tree_2 is being updated, we will insert employees from
    -- emp_adjlist if their manager is in emp_tree_2 and they are not already
    -- contained in emp_tree_2. This basically inserts the tree into the
    -- emp_tree_2 table one level at a time. So then, we just need to count
    -- how many inserts we make, making sure not to count the last one that
    -- doesn't insert anything and making sure to count the first insert of
    -- the root
    WHILE ROW_COUNT() > 0 DO
        SET height = height + 1;
        INSERT INTO emp_tree_2 SELECT emp_id FROM employee_adjlist
            WHERE manager_id IN (SELECT emp_id FROM emp_tree_2)
            AND emp_id NOT IN (SELECT emp_id FROM emp_tree_2);
    END WHILE;
    RETURN height;
END!
DELIMITER ;

-- Testing
-- SELECT tree_depth();

-- [Problem 6]
DROP FUNCTION IF EXISTS emp_reports;
DELIMITER !
-- This function uses employee_nestset to compute how many "direct reports (i.e.
-- children) the specified employee has in the orginization. So basically, it
-- finds out how many employees the specified employee manages.
CREATE FUNCTION emp_reports(
    fn_emp_id INTEGER
) RETURNS INTEGER BEGIN
    DECLARE num_children INTEGER DEFAULT 0;
    DECLARE emp_low INTEGER;
    DECLARE emp_high INTEGER;
    DECLARE emp_num_parents INTEGER DEFAULT 0;

    -- First we select the low attribute of the specified employee into
    -- a declared variable
    SELECT low INTO emp_low
    FROM employee_nestset
    WHERE emp_id = fn_emp_id;

    -- Next we select the high attribute of the specified employee into
    -- a declared variable
    SELECT high INTO emp_high
    FROM employee_nestset
    WHERE emp_id = fn_emp_id;

    -- Now we select the number of parents (which is just the depth - 1)
    -- of the specified employee into a declared variable
    SELECT COUNT(*) INTO emp_num_parents
    FROM employee_nestset AS e
    WHERE e.low < emp_low AND e.high > emp_high;

    -- Now we count how many children are in employee_nestset that:
    -- a) have a range that is contained within the specified employee's range,
    --    i.e. have a low value greater than emp_low and a high value less than
    --    emp_high
    -- b) have a greater number of parents than the specified employee by
    --    1, i.e. are one level below the specified employee
    SELECT COUNT(*) INTO num_children
    FROM employee_nestset AS e
    WHERE e.low > emp_low AND e.high < emp_high AND
        emp_num_parents = (SELECT COUNT(*) AS num_parents
        FROM employee_nestset AS a
        WHERE a.low < e.low AND a.high > e.high) - 1;

    return num_children;
END!
DELIMITER ;

-- Testing
-- SELECT emp_reports(100391);
