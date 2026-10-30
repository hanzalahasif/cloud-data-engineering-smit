--self joins
-- Task 41: List each staff member alongside their manager's full name.
-- If a staff member has no manager (top-level), still show them with NULL for manager name.

select 
    ss.first_name + ' ' + ss.last_name as staff_member,
    st.first_name + ' ' + st.last_name as manager
from sales.staffs ss
left join sales.staffs st
on ss.manager_id = st.staff_id
-- Task 42: Find pairs of products from the same brand that have the exact same list price.
-- Show both product names and the brand name.

select 
    pp1.product_name as product_1,
    pp2.product_name as product_2,
    bb.brand_name
from production.products pp1
join production.products pp2
on pp1.brand_id = pp2.brand_id
and pp1.list_price = pp2.list_price
and pp1.product_id < pp2.product_id
join production.brands bb
on pp1.brand_id = bb.brand_id
--right joins
-- Task 49: List all brands and the products that belong to them.
-- Ensure ALL brands appear, even if they have no products.
-- Use a RIGHT JOIN (products RIGHT JOIN brands).

select bb.brand_name, pp.product_name
from production.products pp
right join production.brands bb
on pp.brand_id = bb.brand_id
-- Task 50: Show all stores and the orders placed at each store.
-- Use a RIGHT JOIN so that stores with zero orders still appear.

select ss.store_name, oo.order_id, oo.order_date
from sales.orders oo
right join sales.stores ss
on oo.store_id = ss.store_id
--left anti joins
-- Task 53: Find all customers who have NEVER placed an order.
-- Hint: LEFT JOIN sales.customers with sales.orders, then filter WHERE order_id IS NULL.

select cc.customer_id,cc.first_name,cc.last_name
from sales.customers cc
left join sales.orders oo
on cc.customer_id=oo.customer_id
where oo.order_id is null
-- Task 54: Find all products that are NOT currently in stock at ANY store.
-- Hint: LEFT JOIN production.products with production.stocks,
-- filter WHERE store_id IS NULL.

select pp.product_id,pp.product_name
from production.products pp
left join production.stocks ps
on pp.product_id=ps.product_id
where ps.store_id is null
-- Task 56: Find all products that have never been ordered.
-- Hint: LEFT JOIN production.products with sales.order_items,
-- filter WHERE order_id IS NULL.

select pp.product_name
from production.products pp
left join sales.order_items oi
on pp.product_id = oi.product_id
where oi.order_id is null
-- Task 60: Find customers who placed orders but never ordered any product from the brand 'Trek'.

select distinct cc.customer_id,cc.first_name,cc.last_name
from sales.customers cc
join sales.orders oo
on cc.customer_id = oo.customer_id
left join
(
    select distinct oo.customer_id
    from sales.orders oo
    join sales.order_items oi
    on oo.order_id = oi.order_id
    join production.products pp
    on oi.product_id = pp.product_id
    join production.brands bb
    on pp.brand_id = bb.brand_id
    where bb.brand_name = 'Trek'
) x
on cc.customer_id = x.customer_id
where x.customer_id is null
--crosss joins
-- Task 45: Generate a list of every possible combination of brand and category.
-- Show brand name and category name.
-- Hint: This is useful when you want to find which brand-category combos have no products.

select bb.brand_name,cc.category_name
from production.brands bb
cross join production.categories cc

-- Task 46: Using the result of a CROSS JOIN between brands and categories,
-- find brand-category combinations that have NO products.
-- LEFT JOIN the cross join result against products and filter for NULLs.

select bb.brand_name,cc.category_name
from production.brands bb
cross join production.categories cc
left join production.products pp
on pp.brand_id=bb.brand_id
and pp.category_id=cc.category_id
where pp.product_id is null