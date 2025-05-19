SELECT  o.order_id, o.total_amount, c.name, c.city

FROM orders_upsert AS o
INNER JOIN
customers_append
    FOR SYSTEM_TIME AS OF o.order_date
    AS c
ON o.customer_id = c.customer_id where order_id='1001';
