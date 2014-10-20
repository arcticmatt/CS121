DROP TABLE IF EXISTS borrowed;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS book;

CREATE TABLE member (
  memb_no       INTEGER AUTO_INCREMENT,
  name          VARCHAR(30) NOT NULL,
  age           INTEGER,
  PRIMARY KEY (memb_no)
);

CREATE TABLE book (
  isbn          CHAR(10),
  title         VARCHAR(100) NOT NULL,
  authors       VARCHAR(500) NOT NULL,
  publisher     VARCHAR(50) NOT NULL,
  PRIMARY KEY (isbn)
);

CREATE TABLE borrowed (
  memb_no       INTEGER,
  isbn          CHAR(10),
  date          DATE,
  PRIMARY KEY (memb_no, isbn),
  FOREIGN KEY (memb_no) REFERENCES member(memb_no),
  FOREIGN KEY (isbn) REFERENCES book(isbn)
);

INSERT INTO member(name, age) VALUES ('Angela', 22);
INSERT INTO member(name, age) VALUES ('Mike', 22);
INSERT INTO member(name, age) VALUES ('Donnie', 35);
INSERT INTO member(name, age) VALUES ('Max', 21);
INSERT INTO member(name, age) VALUES ('Kalpana', 21);
INSERT INTO member(name, age) VALUES ('Bob', 54);
INSERT INTO member(name, age) VALUES ('Sally', 36);
INSERT INTO member(name, age) VALUES ('Catherine', 14);
INSERT INTO member(name, age) VALUES ('David', 17);
INSERT INTO member(name, age) VALUES ('Audrey', 80);
INSERT INTO book VALUES ('3827583928', 'Database System Concepts', 'Abraham Silberschatz', 'McGraw-Hill');
INSERT INTO book VALUES ('2910392839', 'Learning from Data', 'Yaser S. Abu-Mostafa', 'Caltech Publishing');
INSERT INTO book VALUES ('4827398175', 'Understanding the Linux Kernel', 'Daniel P. Bovet', 'McGraw-Hill');
INSERT INTO book VALUES ('3492059483', 'Elements of Information Theory', 'Thomas M. Cover', 'McGraw-Hill');
INSERT INTO book VALUES ('8385738924', 'Structure and Interpretation of Computer Programs', 'Harold Abelson', 'Caltech Publishing');
INSERT INTO book VALUES ('2481575439', 'Intorudction to Algorithms', 'Thomas H. Cormen', 'McGraw-Hill');
INSERT INTO book VALUES ('5683729334', 'The C Programming Language', 'Brian W. Kernighan', 'McGraw-Hill');
INSERT INTO book VALUES ('4958392930', 'Artificial Intelligence: A Modern Approach', 'Stuart Russell', 'McGraw-Hill');
INSERT INTO book VALUES ('2349587523', 'Introduction to the Theory of Computation', 'Michael Sipser', 'Caltech Publishing');
INSERT INTO book VALUES ('5873293847', 'Art of Computer Programming', 'Donald E. Knuth', 'Addison-Wesley Professional');
INSERT INTO book VALUES ('1348729837', 'Code Complete', 'Steve McConnell', 'Prentice Hall');
INSERT INTO book VALUES ('6420947258', 'Learn You a Haskell for Great Good!', 'Miran Lipovaca', 'Prentice Hall');
INSERT INTO book VALUES ('9573782643', 'The Protocols', 'W. Richard Stevens', 'Addison-Wesley Professional');
INSERT INTO book VALUES ('6984209343', 'A Discipline of Programming', 'Edsger W. Dijkstra', 'Prentice Hall');
INSERT INTO book VALUES ('0293734823', 'Joel on Software', 'Joel Spolsky', 'McGraw-Hill');
INSERT INTO book VALUES ('4932948374', 'Applied Cryptography', 'Bruce Scheneier', 'Prentice Hall');
INSERT INTO book VALUES ('5938472938', 'Structured Computer Organization', 'Andrew S. Tanenbaum', 'Prentice Hall');
INSERT INTO book VALUES ('5837294831', 'Raising Chickens 101', 'Dennis R. Pinkston', 'McGraw-Hill');
INSERT INTO book VALUES ('5974582834', 'Operating Systems Concepts', 'Abraham Silberschatz', 'Caltech Publishing');
INSERT INTO book VALUES ('1957493845', 'Skydiving for Beginners', 'John Q. Adams', 'Happy Press');
INSERT INTO book VALUES ('6098234059', 'Introduction to Piano Tuning', 'W. A. Mozart', 'Prentice Hall');
INSERT INTO book VALUES ('5983029384', 'The Art of Origami', 'A. Yokohama', 'Caltech Publishing');
INSERT INTO book VALUES ('6094829340', 'The Official GRE Book', 'Sad College Student', 'ETS');
INSERT INTO book VALUES ('5606948394', 'The Caltech Catalog', 'R. M. Feynman', 'Prentice Hall');
INSERT INTO book VALUES ('0973482738', 'The Science of Tuning Forks', 'Hao R. Yu', 'Microsoft Research');
INSERT INTO borrowed VALUES (1, '3827583928', '2014-03-01');
INSERT INTO borrowed VALUES (1, '4827398175', '2014-03-01');
INSERT INTO borrowed VALUES (1, '4958392930', '2014-09-09');
INSERT INTO borrowed VALUES (1, '0293734823', '2014-08-02');
INSERT INTO borrowed VALUES (1, '5837294831', '2014-08-27');
INSERT INTO borrowed VALUES (1, '8385738924', '2014-08-27');
INSERT INTO borrowed VALUES (1, '0973482738', '2014-08-27');
INSERT INTO borrowed VALUES (1, '5606948394', '2014-01-04');
INSERT INTO borrowed VALUES (2, '5606948394', '2014-06-03');
INSERT INTO borrowed VALUES (2, '6098234059', '2014-05-23');
INSERT INTO borrowed VALUES (2, '5938472938', '2014-03-23');
INSERT INTO borrowed VALUES (2, '6984209343', '2014-12-23');
INSERT INTO borrowed VALUES (2, '6420947258', '2014-12-22');
INSERT INTO borrowed VALUES (2, '1348729837', '2014-12-22');
INSERT INTO borrowed VALUES (3, '1348729837', '2014-12-11');
INSERT INTO borrowed VALUES (3, '2910392839', '2014-11-13');
INSERT INTO borrowed VALUES (4, '3827583928', '2014-11-13');
INSERT INTO borrowed VALUES (4, '4827398175', '2014-11-24');
INSERT INTO borrowed VALUES (4, '3492059483', '2014-11-24');
INSERT INTO borrowed VALUES (4, '2481575439', '2014-02-21');
INSERT INTO borrowed VALUES (4, '5683729334', '2014-02-14');
INSERT INTO borrowed VALUES (4, '4958392930', '2014-02-14');
INSERT INTO borrowed VALUES (4, '0293734823', '2014-02-14');
INSERT INTO borrowed VALUES (4, '5837294831', '2014-02-16');
INSERT INTO borrowed VALUES (4, '5606948394', '2014-02-17');
INSERT INTO borrowed VALUES (6, '3492059483', '2014-05-22');
INSERT INTO borrowed VALUES (6, '5983029384', '2014-05-30');
INSERT INTO borrowed VALUES (6, '1348729837', '2014-05-30');
INSERT INTO borrowed VALUES (8, '0973482738', '2014-04-19');
INSERT INTO borrowed VALUES (9, '0973482738', '2014-04-19');
INSERT INTO borrowed VALUES (9, '3827583928', '2014-12-12');
INSERT INTO borrowed VALUES (10, '3827583928', '2014-12-12');
INSERT INTO borrowed VALUES (10, '4827398175', '2014-09-03');
INSERT INTO borrowed VALUES (10, '3492059483', '2014-03-04');
INSERT INTO borrowed VALUES (10, '2481575439', '2014-03-01');
INSERT INTO borrowed VALUES (10, '5683729334', '2014-01-26');
INSERT INTO borrowed VALUES (10, '4958392930', '2014-06-28');
INSERT INTO borrowed VALUES (10, '0293734823', '2014-02-19');
INSERT INTO borrowed VALUES (10, '5837294831', '2014-01-20');