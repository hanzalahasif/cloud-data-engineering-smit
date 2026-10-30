-- 7.1

SELECT
    product_id,
    product_name,
    list_price,
    category_id,
    ROW_NUMBER() OVER (
        ORDER BY list_price DESC
    ) AS overall_row_number,
    ROW_NUMBER() OVER (
        PARTITION BY category_id
        ORDER BY list_price DESC
    ) AS category_row_number
FROM production.products;


-- 7.2

SELECT
    product_id,
    product_name,
    category_id,
    list_price,
    RANK() OVER (
        PARTITION BY category_id
        ORDER BY list_price DESC
    ) AS price_rank,
    DENSE_RANK() OVER (
        PARTITION BY category_id
        ORDER BY list_price DESC
    ) AS dense_price_rank
FROM production.products
ORDER BY category_id, list_price DESC;


-- 7.3

WITH MonthlyStoreRevenue AS (
    SELECT
        ss.store_id,
        ss.store_name,
        YEAR(so.order_date) AS sales_year,
        MONTH(so.order_date) AS sales_month,
        SUM(
            soi.quantity * soi.list_price * (1 - soi.discount)
        ) AS current_month_revenue
    FROM sales.orders so
    JOIN sales.order_items soi
        ON so.order_id = soi.order_id
    JOIN sales.stores ss
        ON so.store_id = ss.store_id
    WHERE so.order_status = 4
    GROUP BY
        ss.store_id,
        ss.store_name,
        YEAR(so.order_date),
        MONTH(so.order_date)
),
StoreRevenueWithPrevious AS (
    SELECT
        store_id,
        store_name,
        sales_year,
        sales_month,
        current_month_revenue,
        LAG(current_month_revenue) OVER (
            PARTITION BY store_id
            ORDER BY sales_year, sales_month
        ) AS previous_month_revenue
    FROM MonthlyStoreRevenue
)
SELECT
    store_name,
    sales_year,
    sales_month,
    current_month_revenue,
    previous_month_revenue,
    current_month_revenue - previous_month_revenue AS revenue_change
FROM StoreRevenueWithPrevious
ORDER BY
    store_name,
    sales_year,
    sales_month;


-- 7.4

SELECT
    product_name,
    list_price,
    NTILE(5) OVER (
        ORDER BY list_price
    ) AS price_band
FROM production.products
ORDER BY list_price;


-- 7.5

WITH OrderRevenue AS (
    SELECT
        so.order_id,
        so.order_date,
        SUM(
            soi.quantity * soi.list_price * (1 - soi.discount)
        ) AS order_revenue
    FROM sales.orders so
    JOIN sales.order_items soi
        ON so.order_id = soi.order_id
    GROUP BY
        so.order_id,
        so.order_date
)
SELECT
    order_id,
    order_date,
    order_revenue,
    SUM(order_revenue) OVER (
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_revenue
FROM OrderRevenue
ORDER BY order_date, order_id;