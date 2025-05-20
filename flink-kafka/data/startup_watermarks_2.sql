CREATE TABLE orders (
    order_id STRING,
    customer_id STRING,
    order_date TIMESTAMP(3),
    total_amount DECIMAL(10, 2),
    WATERMARK FOR `order_date` AS `order_date` - INTERVAL '5' SECONDS,
    PRIMARY KEY (order_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'orders',
    'properties.bootstrap.servers' = 'broker:9092',
    'key.format' = 'json',
    'value.format' = 'json',
    'scan.watermark.idle-timeout'='5 sec'
);

CREATE TABLE customers (
    customer_id STRING,
    name STRING,
    city STRING,
    epoch_ts AS TO_TIMESTAMP(FROM_UNIXTIME(0)),
    WATERMARK FOR epoch_ts AS epoch_ts,
    PRIMARY KEY (customer_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'customers',
    'properties.bootstrap.servers' = 'broker:9092',
    'key.format' = 'json',
    'value.format' = 'json',
    'scan.watermark.idle-timeout'='5 sec'
);

SET 'sql-client.execution.result-mode' = 'tableau';
