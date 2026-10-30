
-- 5.1 - Write a query using a scalar subquery that returns all products
-- with a list_price above the average price in their brand.
-- Use a correlated subquery in WHERE.

SELECT
    p.product_id,
    p.product_name,
    p.brand_id,
    p.list_price
FROM production.products p
WHERE p.list_price > (
    SELECT AVG(p2.list_price)
    FROM production.products p2
    WHERE p2.brand_id = p.brand_id
);


-- 5.2 - Write a query using IN that returns all orders placed by
-- customers living in New York or California.

SELECT *
FROM sales.orders
WHERE customer_id IN (
    SELECT customer_id
    FROM sales.customers
    WHERE state IN ('NY', 'CA')
);


-- 5.3 - Find customers who never ordered, but fix the NULL trap.

SELECT customer_id
FROM sales.customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM sales.orders o
    WHERE o.customer_id = c.customer_id
);


-- 5.4 - Using a derived table in FROM, find the average number
-- of items per order across all orders.

SELECT AVG(item_count * 1.0) AS avg_items_per_order
FROM (
    SELECT order_id, COUNT(*) AS item_count
    FROM sales.order_items
    GROUP BY order_id
) AS order_counts;


-- 5.5 - Rewrite the EXISTS example using IN.

SELECT c.customer_id
FROM sales.customers c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM sales.orders o
);


-- 5.6 - Use CROSS APPLY to return the top 3 most recent orders
-- for each customer. Show customer_id, first_name, order_id, and order_date.

SELECT
    c.customer_id,
    c.first_name,
    o.order_id,
    o.order_date
FROM sales.customers c
CROSS APPLY (
    SELECT TOP 3
        o.order_id,
        o.order_date
    FROM sales.orders o
    WHERE o.customer_id = c.customer_id
    ORDER BY o.order_date DESC, o.order_id DESC
) AS o;


-- 5.7 - Use ALL to find products whose price is greater than
-- every other product from the same brand.

SELECT
    p.product_id,
    p.product_name,
    p.list_price,
    p.brand_id
FROM production.products p
WHERE p.list_price > ALL (
    SELECT p2.list_price
    FROM production.products p2
    WHERE p2.brand_id = p.brand_id
      AND p2.product_id <> p.product_id
);
