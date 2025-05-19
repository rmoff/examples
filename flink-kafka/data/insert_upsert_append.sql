INSERT INTO customers_append (customer_id, name, city, valid_from)
VALUES
    ('CUST-5678', 'Bucky Barnes', 'Brooklyn', TIMESTAMP '2025-01-02 00:00:00'),
    ('CUST-5678', 'Bucky Barnes', 'Bucharest', TIMESTAMP '2025-05-10 00:00:00');

INSERT INTO customers_upsert (customer_id, name, city, valid_from)
VALUES
    ('CUST-5678', 'Bucky Barnes', 'Brooklyn', TIMESTAMP '2025-01-02 00:00:00'),
    ('CUST-5678', 'Bucky Barnes', 'Bucharest', TIMESTAMP '2025-05-10 00:00:00');

INSERT INTO orders_append (order_id, customer_id, order_date, total_amount)
VALUES
    ('1001', 'CUST-5678', TIMESTAMP '2025-05-09 14:30:00', 199.99),
    ('1004', 'CUST-5678', TIMESTAMP '2025-05-14 11:02:00', 42.25),
    ('1001', 'CUST-5678', TIMESTAMP '2025-05-09 14:30:00', 49.99);

INSERT INTO orders_upsert (order_id, customer_id, order_date, total_amount)
VALUES
    ('1001', 'CUST-5678', TIMESTAMP '2025-05-09 14:30:00', 199.99),
    ('1004', 'CUST-5678', TIMESTAMP '2025-05-14 11:02:00', 42.25),
    ('1001', 'CUST-5678', TIMESTAMP '2025-05-09 14:30:00', 49.99);
