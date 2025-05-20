CREATE TABLE orders (
    order_id STRING,
    customer_id STRING,
    order_date TIMESTAMP(3),
    total_amount DECIMAL(10, 2),
    PRIMARY KEY (order_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'orders',
    'properties.bootstrap.servers' = 'broker:9092',
    'key.format' = 'json',
    'value.format' = 'json'
);

CREATE TABLE customers (
    customer_id STRING,
    name STRING,
    PRIMARY KEY (customer_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'customers',
    'properties.bootstrap.servers' = 'broker:9092',
    'key.format' = 'json',
    'value.format' = 'json'
);

SET 'sql-client.execution.result-mode' = 'tableau';
