CREATE TABLE customers_upsert (
    customer_id STRING,
    name STRING,
    city STRING,
    valid_from TIMESTAMP(3),
    WATERMARK FOR valid_from AS valid_from,
    PRIMARY KEY (customer_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'customers_upsert',
    'properties.bootstrap.servers' = 'broker:9092',
    'key.format' = 'json',
    'value.format' = 'json',
    'scan.watermark.idle-timeout'='5 sec'
);

CREATE TABLE customers_append (
    customer_id STRING,
    name STRING,
    city STRING,
    valid_from TIMESTAMP(3),
    WATERMARK FOR valid_from AS valid_from
) WITH (
    'connector' = 'kafka',
    'topic' = 'customers_append',
    'properties.bootstrap.servers' = 'broker:9092',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'json',
    'scan.watermark.idle-timeout'='5 sec'
);

CREATE TABLE orders_append (
    order_id STRING,
    customer_id STRING,
    order_date TIMESTAMP(3),
    total_amount DECIMAL(10, 2),
    WATERMARK FOR `order_date` AS `order_date` - INTERVAL '5' SECONDS
) WITH (
    'connector' = 'kafka',
    'topic' = 'orders_append',
    'properties.bootstrap.servers' = 'broker:9092',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'json',
    'scan.watermark.idle-timeout'='5 sec'
);

CREATE TABLE orders_upsert (
    order_id STRING,
    customer_id STRING,
    order_date TIMESTAMP(3),
    total_amount DECIMAL(10, 2),
    WATERMARK FOR `order_date` AS `order_date` - INTERVAL '5' SECONDS,
    PRIMARY KEY (order_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'orders_upsert',
    'properties.bootstrap.servers' = 'broker:9092',
    'key.format' = 'json',
    'value.format' = 'json',
    'scan.watermark.idle-timeout'='5 sec'
);

SET 'sql-client.execution.result-mode' = 'tableau';
