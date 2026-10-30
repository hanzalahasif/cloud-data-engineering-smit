
--1.  (Easy)  List every order with the customer's full name, store name, and the full name of the staff member who handled it. 

select sc.first_name+''+ sc.last_name as 'customer_full_name' , so.order_id,ss.store_name, st.first_name+''+ st.last_name as 'staff_full_name'
from sales.customers sc
join sales.orders so
on sc.customer_id=so.customer_id
join sales.stores ss
on so.store_id=ss.store_id
join sales.staffs st
on st.staff_id=so.staff_id
--2.  (Easy)  Show each product with its brand name and category name. Include products even if they have no brand or category assigned. 
select pp.product_name, pb.brand_name,pc.category_name
from production.products pp
left join production.brands pb
on pp.brand_id=pb.brand_id
join production.categories pc
on pc.category_id=pp.category_id

 

--3.  (Medium)  Find all customers who have never placed an order. Return their name, city, and email. 

select sc.first_name+''+ sc.last_name as 'customer_full_name' ,sc.city,sc.email
from sales.customers sc
join sales.orders so
on sc.customer_id=so.customer_id
where order_id is null

--GROUP BY 

--4.  (Easy)  Calculate total revenue per store. c = quantity * list_price * (1 - discount). Sort from highest to lowest. 

 select ss.store_name,sum((oi.quantity * oi.list_price  * (1 - oi.discount))) as 'revenue'
 from sales.stores ss
 join sales.orders so
 on ss.store_id=so.store_id
 join sales.order_items oi
 on oi.order_id=so.order_id
 group by ss.store_name
 order by revenue desc
 
--5.  (Medium)  For each brand, show the number of products, the average list price,
--and the highest list price. Only include brands with more than 5 products. 
select pb.brand_name,count(pp.product_id) 'count',AVG(pp.list_price) 'avg',
max(pp.list_price) 'max'
from production.products pp
join production.brands pb
on pp.brand_id=pb.brand_id
group by pb.brand_name
having COUNT(pp.product_id) > 5

--6.  (Medium)  Show the number of orders and total revenue per month for the
--year 2017, ordered chronologically. 

 select count(so.order_id) 'count',sum((oi.quantity * oi.list_price  * (1 - oi.discount))) as 'revenue'
 from
 sales.orders so
 join sales.order_items oi
 on oi.order_id=so.order_id
 where year(so.order_date)='2017'
group by MONTH(so.order_date)


--Subqueries 

--7.  (Medium)  Find all products priced above the average list price
--of their own category. 

--Hint: Use a correlated subquery. 
select  pp1.list_price
from production.products pp1 where  pp1.list_price  >
 (select avg(pp.list_price)
 from production.products pp
 group by category_id
 having pp.category_id=pp1.category_id)

--8.  (Medium)  List the customers who have placed more orders
--than the average number of orders per customer. 
select sc.first_name+''+ sc.last_name as 'customer_full_name' 
from sales.customers sc
join sales.orders so
on sc.customer_id=so.customer_id
group by sc.customer_id,sc.first_name, sc.last_name
having count(so.order_id) > (select avg(counts) from
(select so.customer_id, count(so.order_id) as "counts"
from sales.orders  so
group by so.customer_id ) x )



--CTEs 

--9.  (Hard)  Using a CTE, calculate each customer's total spend, 
--then return the top 10 customers with their spend and rank. 
--Add a second CTE that labels each customer as "High" 
--(above the overall average spend) or "Regular". 


 with  customer_total_spend
 as (
 select  sc.customer_id as 'cid',
 sum(oi.list_price * oi.quantity) as 'total_spend'
 from sales.customers sc
 join sales.orders so
 on so.customer_id=sc.customer_id
 join sales.order_items oi
 on oi.order_id=so.order_id
 group by sc.customer_id
 ),  cs_label  as(
 select cid,total_spend ,avg(total_spend) over()as 'avg_spend'
 from 
 customer_total_spend
 )
 select top 10  cid,total_spend,
 CASE 
        WHEN    total_spend > avg_spend  then 'HIGH'
        else 'regular'
    END              AS spend_status
	from cs_label
	order by total_spend desc;
 



--10.  (Hard)  Using CTEs, find the best-selling product (by quantity)
--in each category, and show how much of that product's 
--stock is currently available across all stores. 

--Hint: Use ROW_NUMBER() or RANK() partitioned by category, then join to production.stocks. 
select * from sales.order_items
WITH by_quantity AS (
    SELECT 
        oi.product_id AS pid,
        SUM(oi.quantity) AS qsum,
        pp.category_id
    FROM sales.order_items oi
    JOIN production.products pp
        ON pp.product_id = oi.product_id
    GROUP BY oi.product_id, pp.category_id
),
product_stock AS (
    SELECT 
        pid,
        SUM(ps.quantity) AS total_stock
    FROM by_quantity
    JOIN production.stocks ps
        ON pid = ps.product_id
    GROUP BY pid
),
ranked_products AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY category_id
               ORDER BY qsum DESC
           ) AS rn
    FROM by_quantity
)
SELECT 
    rp.category_id,
    rp.pid,
    rp.qsum,
    ps.total_stock
FROM ranked_products rp
JOIN product_stock ps
    ON rp.pid = ps.pid
WHERE rp.rn = 1;                                                                                                                                                                    )

--Bonus Challenges 

--Rewrite Q8 using a CTE instead of a subquery and compare readability. 

--For Q4, add a column showing each store's percentage share of total company revenue. 