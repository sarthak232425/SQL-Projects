-- Connect to database (in psql: \c expense_tracker)

-- Create tables
CREATE TABLE payment_methods (
    method_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    category_id INT REFERENCES categories(category_id),
    payment_method_id INT REFERENCES payment_methods(method_id),
    created_at TIMESTAMP DEFAULT NOW()
);
---------------------------------------------
-------------INSERTED VALUES-----------------
---------------------------------------------
-- Insert payment methods
INSERT INTO payment_methods (name, description) VALUES
('Cash', 'Physical currency'),
('Credit Card', 'VISA ending in 1234'),
('Debit Card', 'Mastercard ending in 5678'),
('Bank Transfer', 'Direct bank transfer'),
('Mobile Payment', 'Apple Pay/Google Pay');

-- Insert categories
INSERT INTO categories (name, description) VALUES
('Food', 'Groceries and dining out'),
('Transportation', 'Public transport, gas, rideshares'),
('Housing', 'Rent, mortgage, utilities'),
('Entertainment', 'Movies, concerts, hobbies'),
('Healthcare', 'Medical expenses, insurance'),
('Education', 'Courses, books, learning materials');

-- Insert sample transactions
INSERT INTO transactions (amount, description, date, category_id, payment_method_id) VALUES
(75.50, 'Weekly groceries', '2023-05-15', 1, 2),
(45.00, 'Dinner with friends', '2023-05-18', 1, 3),
(120.00, 'Monthly metro pass', '2023-05-01', 2, 4),
(1500.00, 'Rent payment', '2023-05-01', 3, 5),
(12.99, 'Netflix subscription', '2023-05-10', 4, 3),
(85.00, 'Doctor visit', '2023-05-22', 5, 1);

---------------------------------------------
----------------------QUERIES----------------
---------------------------------------------
-- Get all transactions
SELECT * FROM transactions;

-- View transactions with category and payment method names
SELECT 
    t.transaction_id,
    t.date,
    t.amount,
    c.name AS category,
    pm.name AS payment_method,
    t.description
FROM transactions t
JOIN categories c ON t.category_id = c.category_id
JOIN payment_methods pm ON t.payment_method_id = pm.method_id
ORDER BY t.date DESC;

-- Get total spending by category
SELECT 
    c.name AS category,
    SUM(t.amount) AS total_spent
FROM transactions t
JOIN categories c ON t.category_id = c.category_id
GROUP BY c.name
ORDER BY total_spent DESC;

-- Update a transaction amount
UPDATE transactions 
SET amount = 80.00 
WHERE transaction_id = 1;

-- Change a transaction's category
UPDATE transactions
SET category_id = (SELECT category_id FROM categories WHERE name = 'Entertainment')
WHERE transaction_id = 5;

-- Update payment method description
UPDATE payment_methods
SET description = 'VISA ending in 4321'
WHERE method_id = 2;