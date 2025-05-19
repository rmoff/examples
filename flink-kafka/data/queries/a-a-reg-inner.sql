SELECT  o.order_id, o.total_amount, c.name, c.city

FROM orders_append AS o
INNER JOIN
customers_append

AS c ON o.customer_id = c.customer_id where order_id='1001';
