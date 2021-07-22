INSERT INTO users (first_name, last_name, email, credit_card) VALUES ('John', 'Doe', 'john.doe@example.com', '5555-5555-5555-5555');
INSERT INTO users (first_name, last_name, email, credit_card) VALUES ('Max', 'Krivich', 'max@example.com', '2222-2222-2222-2222');
UPDATE users SET first_name='Mike', email='mike@example.com'  WHERE email='max@example.com';
DELETE FROM users WHERE email='max@example.com';