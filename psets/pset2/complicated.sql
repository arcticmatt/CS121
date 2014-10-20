-- [Problem 1a]
SELECT DISTINCT name FROM student NATURAL JOIN takes INNER JOIN course WHERE
    course.dept_name = 'Comp. Sci.' AND takes.course_id = course.course_id;

-- [Problem 1c]
SELECT dept_name, MAX(salary) AS max_salary FROM instructor GROUP BY dept_name;

-- [Problem 1d]
SELECT min(max_salary) AS min_salary FROM (SELECT dept_name, MAX(salary) AS
    max_salary FROM instructor GROUP BY dept_name) AS max_salaries;

-- [Problem 2a]
INSERT INTO course VALUES ('CS-001', 'Weekly Seminar', 'Comp. Sci.', 0);

-- [Problem 2b]
INSERT INTO section VALUES ('CS-001', 1, 'Autumn', 2009, NULL, NULL, NULL);

-- [Problem 2c]
-- This is a two-liner
-- CREATE VIEW course_insert_view AS SELECT DISTINCT ID, section.course_id,
    -- section.sec_id, section.semester, section.year FROM (student NATURAL JOIN
    -- takes INNER JOIN section) WHERE section.course_id = 'CS-001' AND
    -- dept_name = 'Comp. Sci.';

-- INSERT INTO takes SELECT * FROM course_insert_view natural join (SELECT grade
    -- FROM takes WHERE grade IS UNKNOWN) AS temp;
INSERT INTO takes SELECT DISTINCT ID, section.course_id, section.sec_id,
    section.semester, section.year, NULL FROM (student INNER JOIN section)
    WHERE section.course_id = 'CS-001' AND dept_name = 'Comp. Sci.';

-- [Problem 2d]
DELETE FROM takes WHERE (ID) IN (SELECT ID FROM student WHERE name = 'Chavez');

-- [Problem 2e]
-- If you run this delete statement without first deleting offerings (sections)
-- of this course, it will delete it from section and from takes.
DELETE FROM course WHERE course_id = 'CS-001';

-- [Problem 2f]
DELETE FROM takes WHERE (course_id) IN (SELECT course_id FROM course
    WHERE title LIKE '%database%');

-- [Problem 3a]
SELECT DISTINCT name FROM (member NATURAL JOIN book NATURAL JOIN borrowed) WHERE
    publisher = 'McGraw-Hill';

-- [Problem 3b]
select count(isbn) as book_count from book group by publisher having
publisher = 'McGraw-Hill';

-- [Problem 3c]



-- [Problem 3d]


