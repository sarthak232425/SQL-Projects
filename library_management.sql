
-- Connect to the database (in psql: \c library_management)
-- Then create tables:

-- Authors table
CREATE TABLE Authors (
    author_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50)
);

-- Books table
CREATE TABLE Books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author_id INT,
    isbn VARCHAR(20) UNIQUE,
    published_date DATE,
    available_copies INT DEFAULT 1,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id)
);

-- Members table
CREATE TABLE Members (
    member_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    join_date DATE DEFAULT CURRENT_DATE,
    active BOOLEAN DEFAULT TRUE
);

-- Loans table
CREATE TABLE Loans (
    loan_id SERIAL PRIMARY KEY,
    book_id INT,
    member_id INT,
    loan_date DATE DEFAULT CURRENT_DATE,
    due_date DATE,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);


---------------------------------------------
-------------INSERTED VALUES-----------------
---------------------------------------------
-- Insert authors
INSERT INTO Authors (name, birth_date, nationality) VALUES 
('J.K. Rowling', '1965-07-31', 'British'),
('George R.R. Martin', '1948-09-20', 'American'),
('Agatha Christie', '1890-09-15', 'British');

-- Insert books
INSERT INTO Books (title, author_id, isbn, published_date, available_copies) VALUES
('Harry Potter and the Philosopher''s Stone', 1, '9780747532743', '1997-06-26', 5),
('A Game of Thrones', 2, '9780553103540', '1996-08-01', 3),
('Murder on the Orient Express', 3, '9780062073495', '1934-01-01', 2);

-- Insert members
INSERT INTO Members (name, email, phone) VALUES
('John Smith', 'john@example.com', '555-1234'),
('Sarah Johnson', 'sarah@example.com', '555-5678'),
('Mike Brown', 'mike@example.com', '555-9012');


---------------------------------------------
----------------------QUERIES----------------
---------------------------------------------
-- Get all books
SELECT * FROM Books;

-- Get available books
SELECT title, available_copies FROM Books WHERE available_copies > 0;

-- Find books by author
SELECT b.title, b.published_date 
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
WHERE a.name = 'J.K. Rowling';

-- Get active members
SELECT name, email, join_date FROM Members WHERE active = TRUE;

-- Update book availability
UPDATE Books SET available_copies = 4 WHERE book_id = 1;

-- Update member info
UPDATE Members SET phone = '555-4321' WHERE member_id = 1;

-- Extend loan due date
UPDATE Loans SET due_date = due_date + INTERVAL '7 days' WHERE loan_id = 3;

-- Deactivate member (soft delete)
UPDATE Members SET active = true WHERE member_id = 3;

-- Delete a book (if no active loans)
DELETE FROM Books 
WHERE book_id = 5 
AND NOT EXISTS (
    SELECT 1 FROM Loans 
    WHERE book_id = 5 AND return_date IS NULL
);

-- Borrow a book
BEGIN;
INSERT INTO Loans (book_id, member_id, due_date)
VALUES (1, 2, CURRENT_DATE + INTERVAL '14 days');
UPDATE Books SET available_copies = available_copies - 1 WHERE book_id = 1;
COMMIT;

-- Return a book
BEGIN;
UPDATE Loans SET return_date = CURRENT_DATE 
WHERE book_id = 1 AND member_id = 2 AND return_date IS NULL;
UPDATE Books SET available_copies = available_copies + 1 WHERE book_id = 1;
COMMIT;

-- Get overdue books
SELECT b.title, m.name, l.due_date, 
       (CURRENT_DATE - l.due_date) AS days_overdue
FROM Loans l
JOIN Books b ON l.book_id = b.book_id
JOIN Members m ON l.member_id = m.member_id
WHERE l.return_date IS NULL AND l.due_date < CURRENT_DATE;