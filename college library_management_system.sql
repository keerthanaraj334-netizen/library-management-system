create database librarydb;
use librarydb;
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100),
    member_type VARCHAR(20),
    joined_date DATE
);
CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(150),
    author VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    copies_available INT
);
CREATE TABLE issues (
    issue_id INT PRIMARY KEY,
    member_id INT,
    book_id INT,
    issue_date DATE,
    due_date DATE,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);
INSERT INTO members
(member_id, member_name, member_type, joined_date)
VALUES
(1, 'Rahul Sharma', 'Student', '2025-01-10'),
(2, 'Priya Patil', 'Student', '2025-02-15'),
(3, 'Amit Kumar', 'Faculty', '2025-03-20'),
(4, 'Sneha Reddy', 'Student', '2025-04-05'),
(5, 'Dr. Meena Rao', 'Faculty', '2025-05-12');
INSERT INTO books
(book_id, title, author, category, price, copies_available)
VALUES
(1, 'Python Programming', 'Guido Rossum', 'Computer', 450.00, 3),
(2, 'Database Management', 'Korth', 'Computer', 550.00, 2),
(3, 'The Alchemist', 'Paulo Coelho', 'Fiction', 300.00, 4),
(4, 'Wings of Fire', 'APJ Abdul Kalam', 'Biography', 350.00, 1),
(5, 'Physics Fundamentals', 'H C Verma', 'Science', 600.00, 5);
INSERT INTO issues
(issue_id, member_id, book_id,
 issue_date, due_date, return_date)
VALUES
(1001, 1, 1, '2026-10-01', '2026-10-15', '2026-10-18'),
(1002, 2, 2, '2026-10-20', '2026-11-03', NULL),
(1003, 3, 3, '2026-11-01', '2026-11-15', NULL),
(1004, 1, 4, '2026-10-10', '2026-10-24', '2026-10-23'),
(1005, 4, 1, '2026-10-25', '2026-11-08', NULL);
SELECT
    category,
    COUNT(*) AS total_titles,
    SUM(copies_available) AS total_copies
FROM books
GROUP BY category;
SELECT
    b.book_id,
    b.title,
    COUNT(i.issue_id) AS total_borrowed
FROM books b
JOIN issues i
    ON b.book_id = i.book_id
GROUP BY b.book_id, b.title
ORDER BY total_borrowed DESC
LIMIT 5;
SELECT
    m.member_id,
    m.member_name,
    m.member_type
FROM members m
LEFT JOIN issues i
    ON m.member_id = i.member_id
WHERE i.issue_id IS NULL;
SELECT
    m.member_name,
    b.title,
    i.issue_date,
    i.due_date
FROM issues i
JOIN members m
    ON i.member_id = m.member_id
JOIN books b
    ON i.book_id = b.book_id
WHERE i.return_date IS NULL;
SELECT
    m.member_name,
    b.title,
    i.due_date,
    i.return_date,
    DATEDIFF(i.return_date, i.due_date) AS days_late,
    DATEDIFF(i.return_date, i.due_date) * 2 AS fine
FROM issues i
JOIN members m
    ON i.member_id = m.member_id
JOIN books b
    ON i.book_id = b.book_id
WHERE i.return_date > i.due_date;
SELECT
    m.member_id,
    m.member_name,
    SUM(
        DATEDIFF(i.return_date, i.due_date) * 2
    ) AS total_fine
FROM members m
JOIN issues i
    ON m.member_id = i.member_id
WHERE i.return_date > i.due_date
GROUP BY m.member_id, m.member_name;
SELECT
    m.member_type,
    COUNT(i.issue_id) AS total_borrowed
FROM members m
LEFT JOIN issues i
    ON m.member_id = i.member_id
GROUP BY m.member_type;
SELECT
    m.member_id,
    m.member_name,
    COUNT(i.issue_id) AS total_borrowed,
    RANK() OVER (
        ORDER BY COUNT(i.issue_id) DESC
    ) AS member_rank
FROM members m
LEFT JOIN issues i
    ON m.member_id = i.member_id
GROUP BY m.member_id, m.member_name;
SELECT
    b.category,
    COUNT(i.issue_id) AS total_issues
FROM books b
JOIN issues i
    ON b.book_id = i.book_id
GROUP BY b.category
ORDER BY total_issues DESC;
SELECT
    b.book_id,
    b.title,
    b.copies_available
FROM books b
WHERE b.copies_available = 0
AND EXISTS (
    SELECT 1
    FROM issues i
    WHERE i.book_id = b.book_id
    AND i.return_date IS NULL
);
DELIMITER //

CREATE PROCEDURE member_history(IN id INT)
BEGIN
    SELECT m.member_name, b.title,
           i.issue_date, i.due_date, i.return_date
    FROM issues i
    JOIN members m ON i.member_id = m.member_id
    JOIN books b ON i.book_id = b.book_id
    WHERE i.member_id = id;
END //

DELIMITER ;
CALL member_history(1);

use librarydb;
DELIMITER //

CREATE TRIGGER reduce_copies
AFTER INSERT ON issues_copy
FOR EACH ROW
BEGIN
    UPDATE books
    SET copies_available = copies_available - 1
    WHERE book_id = NEW.book_id;
END //

DELIMITER ;
INSERT INTO issues_copy
(issue_id, member_id, book_id, issue_date, due_date, return_date)
VALUES
(1006, 2, 2, '2026-11-10', '2026-11-24', NULL);
SELECT book_id, title, copies_available
FROM books
WHERE book_id = 2;