--Section 3 — JOINs 

-- Task 12: List every product along with its brand name and category name

SELECT
    p.product_name,
    b.brand_name,
    c.category_name
FROM production.products AS p
INNER JOIN production.brands AS b
    ON p.brand_id = b.brand_id
INNER JOIN production.categories AS c
    ON p.category_id = c.category_id;


-- Task 13: List all orders with the customer's full name (first_name + last_name), order date, and order status

SELECT
    o.order_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    o.order_date,
    o.order_status
FROM sales.orders AS o
INNER JOIN sales.customers AS c
    ON o.customer_id = c.customer_id;


-- Task 14: Show every order item with the product name, quantity, list price, and discount

SELECT
    oi.order_id,
    p.product_name,
    oi.quantity,
    oi.list_price,
    oi.discount
FROM sales.order_items AS oi
INNER JOIN production.products AS p
    ON oi.product_id = p.product_id;


-- Task 15: List each staff member's full name alongside their store name

SELECT
    s.first_name + ' ' + s.last_name AS staff_name,
    st.store_name
FROM sales.staffs AS s
INNER JOIN sales.stores AS st
    ON s.store_id = st.store_id;
 

--Task 16:  List staff members along with their manager's full name. 

--Hint: Use a self-join on the sales.staffs table using manager_id. 
select ss.first_name + ss.last_name as "staff_member",st.first_name + st.last_name as "manager"
from sales.staffs ss
join sales.staffs st
on ss.manager_id=st.staff_id
select * from sales.staffs
--Task 17:  Show all stores and the products they have in stock, including the product name and quantity. Only show items where quantity > 0. 
select ss.store_name,pp.product_name,pc.quantity
from sales.stores ss
join production.stocks pc
on pc.store_id=ss.store_id
join production.products pp
on pp.product_id=pc.product_id
where pc.quantity > 0

-- Task 18: List all customers who placed at least one order.Show customer name and order date

SELECT
    c.first_name + ' ' + c.last_name AS customer_name,
    o.order_date
FROM sales.customers AS c
INNER JOIN sales.orders AS o
    ON c.customer_id = o.customer_id;


-- Task 19: List ALL customers and their orders (if any).Customers who never ordered should still appear with NULL order data

SELECT
    c.first_name + ' ' + c.last_name AS customer_name,
    o.order_id,
    o.order_date,
    o.order_status
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
    ON c.customer_id = o.customer_id;