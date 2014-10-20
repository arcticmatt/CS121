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
SELECT name FROM (member NATURAL JOIN book NATURAL JOIN borrowed) WHERE
    publisher = 'McGraw-Hill' GROUP BY memb_no, name HAVING COUNT(DISTINCT isbn)
    = (SELECT COUNT(DISTINCT isbn) AS count_mcgraw FROM book WHERE
    publisher = 'McGraw-Hill');

-- [Problem 3c]
SELECT publisher, name FROM (member NATURAL JOIN book NATURAL JOIN borrowed)
    GROUP BY publisher, name HAVING COUNT(DISTINCT isbn) > 5;

-- [Problem 3d]
SELECT AVG(book_count) AS avg_count FROM ( SELECT COUNT(DISTINCT isbn) AS
    book_count FROM (member NATURAL LEFT OUTER JOIN borrowed) GROUP BY name)
    AS book_counts;
