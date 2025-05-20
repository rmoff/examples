INSERT INTO customers (customer_id, name, city, valid_from)
VALUES
    ('CUST-3456', 'Yelena Belova', 'New York', TIMESTAMP '2025-01-01 00:00:00'),
    ('CUST-5678', 'Bucky Barnes', 'Brooklyn', TIMESTAMP '2025-01-02 00:00:00'),
    ('CUST-9012', 'Valentina Allegra de Fontaine', 'Moscow', TIMESTAMP '2025-01-01 00:00:00'),
    ('CUST-5678', 'Bucky Barnes', 'Bucharest', TIMESTAMP '2025-05-10 00:00:00');

INSERT INTO orders (order_id, customer_id, order_date, total_amount)
VALUES
    ('1001', 'CUST-5678', TIMESTAMP '2025-05-09 14:30:00', 199.99),
    ('1002', 'CUST-3456', TIMESTAMP '2025-05-09 15:45:00', 349.50),
    ('1003', 'CUST-5678', TIMESTAMP '2025-05-09 16:15:00', 75.25),
    ('1004', 'CUST-5678', TIMESTAMP '2025-05-14 11:02:00', 42.25);
