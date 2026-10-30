--Assignment Tasks
--Task 1 — Build the Sales Detail Dataset (6 marks)
--Management needs a detailed sales dataset for analysis
--. Return one row per order item containing:
--order_id and order_date
--customer full name
--store name
--staff full name
--product name
--category name
--brand name
--quantity, list_price, discount
--calculated net_line_revenue




--Include only completed orders (order_status = 4).
--Sort the result from newest order to oldest.
-- Task 1 — Build the Sales Detail Dataset

SELECT
    so.order_id,
    so.order_date,
    sc.first_name + ' ' + sc.last_name AS customer_full_name,
    ss.store_name,
    st.first_name + ' ' + st.last_name AS staff_full_name,
    pp.product_name,
    pc.category_name,
    pb.brand_name,
    soi.quantity,
    soi.list_price,
    soi.discount,
    soi.quantity * soi.list_price * (1 - soi.discount) AS net_line_revenue

FROM sales.order_items soi

JOIN sales.orders so
    ON soi.order_id = so.order_id

JOIN sales.customers sc
    ON so.customer_id = sc.customer_id

JOIN sales.stores ss
    ON so.store_id = ss.store_id

JOIN sales.staffs st
    ON so.staff_id = st.staff_id

JOIN production.products pp
    ON soi.product_id = pp.product_id

JOIN production.categories pc
    ON pp.category_id = pc.category_id

JOIN production.brands pb
    ON pp.brand_id = pb.brand_id

WHERE so.order_status = 4

ORDER BY so.order_date DESC;
--Task 2 — Store Performance Summary (5 marks)
--Create a store-level performance report for completed orders showing:
--store name
--number of distinct orders
--total units sold
--total net revenue
--average order value
--Return one row per store and order the stores 
--from highest to lowest total net revenue.


SELECT
    ss.store_name,
    COUNT(DISTINCT so.order_id) AS number_of_orders,
    SUM(soi.quantity) AS total_units_sold,
    SUM(soi.quantity * soi.list_price * (1 - soi.discount)) AS total_net_revenue,
    SUM(soi.quantity * soi.list_price * (1 - soi.discount))
        / COUNT(DISTINCT so.order_id) AS average_order_value

FROM sales.orders so

JOIN sales.order_items soi
    ON so.order_id = soi.order_id

JOIN sales.stores ss
    ON so.store_id = ss.store_id

WHERE so.order_status = 4

GROUP BY ss.store_name

ORDER BY total_net_revenue DESC;
--Task 3 — High-Value Customers (5 marks)
--Management wants to identify high-value customers.
--Return customers whose total completed-order spending is greater than the 
--average total spending of customers who have completed orders.
WITH CustomerSpending AS (
    SELECT
        sc.customer_id,
        sc.first_name + ' ' + sc.last_name AS customer_full_name,
        SUM(soi.quantity * soi.list_price * (1 - soi.discount)) AS total_spending
    FROM sales.orders so
    JOIN sales.order_items soi
        ON so.order_id = soi.order_id
    JOIN sales.customers sc
        ON so.customer_id = sc.customer_id
    WHERE so.order_status = 4
    GROUP BY
        sc.customer_id,
        sc.first_name,
        sc.last_name
),
AverageSpending AS (
    SELECT
        AVG(total_spending) AS avg_total_spending
    FROM CustomerSpending
)
SELECT
    cs.customer_id,
    cs.customer_full_name,
    cs.total_spending
FROM CustomerSpending cs
CROSS JOIN AverageSpending av
WHERE cs.total_spending > av.avg_total_spending
ORDER BY cs.total_spending DESC;

--Show customer_id, customer name, completed order count, and total spending. Order the result by total spending descending.
--Task 4 — Inventory Risk Report (5 marks)
--Operations wants to identify inventory risk.
--Return products where the stock quantity is below 5 in at least one store.

--Show product name, store name, current quantity, category name,
--and brand name. Products with zero stock should appear first, 
--followed by the lowest remaining quantities.
WITH InventoryRisk AS (
    SELECT
        pp.product_name,
        ss.store_name,
        ps.quantity AS current_quantity,
        pc.category_name,
        pb.brand_name
    FROM production.stocks ps
    JOIN production.products pp
        ON ps.product_id = pp.product_id
    JOIN sales.stores ss
        ON ps.store_id = ss.store_id
    JOIN production.categories pc
        ON pp.category_id = pc.category_id
    JOIN production.brands pb
        ON pp.brand_id = pb.brand_id
)
SELECT
    product_name,
    store_name,
    current_quantity,
    category_name,
    brand_name
FROM InventoryRisk
WHERE current_quantity < 5
ORDER BY current_quantity ASC;
--Task 5 — Top Products Within Each Category (6 marks)
--For each product category, identify the top 3 products by total net revenue
--from completed orders.

--Return category name, product name, total units sold, 
--total net revenue, and the product's position within its category.
--
--Tied products must receive the same position and the next position --
--should not contain gaps.
WITH ProductRevenue AS (
    SELECT
        pc.category_id,
        pc.category_name,
        pp.product_id,
        pp.product_name,
        SUM(soi.quantity) AS total_units_sold,
        SUM(soi.quantity * soi.list_price * (1 - soi.discount)) AS total_net_revenue
    FROM sales.orders so
    JOIN sales.order_items soi
        ON so.order_id = soi.order_id
    JOIN production.products pp
        ON soi.product_id = pp.product_id
    JOIN production.categories pc
        ON pp.category_id = pc.category_id
    WHERE so.order_status = 4
    GROUP BY
        pc.category_id,
        pc.category_name,
        pp.product_id,
        pp.product_name
),
RankedProducts AS (
    SELECT
        category_name,
        product_name,
        total_units_sold,
        total_net_revenue,
        DENSE_RANK() OVER (
            PARTITION BY category_id
            ORDER BY total_net_revenue DESC
        ) AS product_position
    FROM ProductRevenue
)
SELECT
    category_name,
    product_name,
    total_units_sold,
    total_net_revenue,
    product_position
FROM RankedProducts
WHERE product_position <= 3
ORDER BY category_name, product_position;
--Task 6 — Monthly Sales Trend (6 marks)
--Create a monthly sales trend for completed orders.

--For each calendar month return:
--year
--month
--total net revenue
--previous month's total net revenue
--revenue change from the previous month
WITH MonthlySales AS (
    SELECT
        YEAR(so.order_date) AS sales_year,
        MONTH(so.order_date) AS sales_month,
        SUM(soi.quantity * soi.list_price * (1 - soi.discount)) AS total_net_revenue
    FROM sales.orders so
    JOIN sales.order_items soi
        ON so.order_id = soi.order_id
    WHERE so.order_status = 4
    GROUP BY
        YEAR(so.order_date),
        MONTH(so.order_date)
),
SalesWithPrevious AS (
    SELECT
        sales_year,
        sales_month,
        total_net_revenue,
        LAG(total_net_revenue) OVER (
            ORDER BY sales_year, sales_month
        ) AS previous_month_net_revenue
    FROM MonthlySales
)
SELECT
    sales_year AS year,
    sales_month AS month,
    total_net_revenue,
    previous_month_net_revenue,
    total_net_revenue - previous_month_net_revenue AS revenue_change
FROM SalesWithPrevious
ORDER BY
    sales_year,
    sales_month;
--The first month may have NULL for the previous-month comparison.
--Sort chronologically.
--Task 7 — Reusable Reporting View (4 marks)
--Create a view named sales.vw_customer_sales_summary that returns
---one row per customer and includes:
--customer_id
--customer full name
--total number of completed orders
--total units purchased
--total net revenue
--most recent completed order date

--Customers with no completed orders must still be represented where possible,
--with appropriate zero/NULL values.
CREATE VIEW sales.vw_customer_sales_summary AS
SELECT
    sc.customer_id,
    sc.first_name + ' ' + sc.last_name AS customer_full_name,
    COUNT(DISTINCT so.order_id) AS total_completed_orders,
    COALESCE(SUM(soi.quantity), 0) AS total_units_purchased,
    COALESCE(
        SUM(soi.quantity * soi.list_price * (1 - soi.discount)),
        0
    ) AS total_net_revenue,
    MAX(so.order_date) AS most_recent_completed_order_date
FROM sales.customers sc
LEFT JOIN sales.orders so
    ON sc.customer_id = so.customer_id
    AND so.order_status = 4
LEFT JOIN sales.order_items soi
    ON so.order_id = soi.order_id
GROUP BY
    sc.customer_id,
    sc.first_name,
    sc.last_name;
--Task 8 — Safe Data Modification (4 marks)
--A customer with customer_id = 1 has requested that their phone number
--be changed to '(999) 555-0101'.


--Write SQL that performs this update inside an explicit transaction.
--Include a validation query after the UPDATE and
--show how the change can be rolled back during testing
--so the assessment database is not permanently changed.
begin transaction 
update sales.customers
set phone ='(999) 555-0101'
where customer_id = 1
rollback transaction

--Task 9 — Store Sales Procedure (6 marks)
--Create a stored procedure named sales.usp_store_sales_report with these input parameters:
--@store_id
--@start_date
--@end_date

--The procedure should return completed-order sales 
--for the requested store and date range, grouped by product.
--Return product name, total units sold, and total net revenue, 
--ordered by revenue descending.

--Add appropriate error handling for invalid date ranges 
--where @start_date is later than @end_date.
CREATE PROCEDURE sales.usp_store_sales_report
    @store_id INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    BEGIN TRY

        IF @start_date > @end_date
        BEGIN
            THROW 50001, 'Invalid date range: start date cannot be later than end date.', 1;
        END;

        SELECT
            pp.product_name,
            SUM(soi.quantity) AS total_units_sold,
            SUM(soi.quantity * soi.list_price * (1 - soi.discount)) AS total_net_revenue
        FROM sales.orders so
        JOIN sales.order_items soi
            ON so.order_id = soi.order_id
        JOIN production.products pp
            ON soi.product_id = pp.product_id
        WHERE so.store_id = @store_id
          AND so.order_status = 4
          AND so.order_date BETWEEN @start_date AND @end_date
        GROUP BY
            pp.product_id,
            pp.product_name
        ORDER BY total_net_revenue DESC;

    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS error_message;
    END CATCH
END;
--Task 10 — Management Insight Query (3 marks)
--Write one additional SQL query that you believe would provide useful insight 
--to BikeStores management using at least three tables.

--Below the query, add a SQL comment of no more than three lines explaining:
--1. the business question,
--2. what the result measures, and
--3. why management should care about it.
SELECT
    MONTH(so.order_date) AS sales_month,
    DATENAME(MONTH, so.order_date) AS month_name,
    SUM(soi.quantity) AS total_units_sold
FROM sales.orders so
JOIN sales.order_items soi
    ON so.order_id = soi.order_id
JOIN production.products pp
    ON soi.product_id = pp.product_id
WHERE so.order_status = 4
GROUP BY
    MONTH(so.order_date),
    DATENAME(MONTH, so.order_date)
ORDER BY total_units_sold DESC;

-- Business question: Which month has the highest sales?
-- Result measures: Total units sold in each month.
-- Management can use this to prepare stock and resources for high-sales months.
