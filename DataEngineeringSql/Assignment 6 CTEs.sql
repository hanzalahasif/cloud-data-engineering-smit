
-- 6.2

WITH cte_high_value_products AS (
    SELECT
        product_id,
        product_name,
        list_price,
        category_id
    FROM production.products
    WHERE list_price > 2000
)
SELECT
    chvp.product_id,
    chvp.product_name,
    chvp.list_price,
    pc.category_name
FROM cte_high_value_products chvp
JOIN production.categories pc
    ON chvp.category_id = pc.category_id
WHERE pc.category_name = 'Mountain Bikes';


-- 6.3

WITH OrderCounts AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM sales.orders
    GROUP BY customer_id
),
CustomerRevenue AS (
    SELECT
        so.customer_id,
        SUM(soi.quantity * soi.list_price * (1 - soi.discount)) AS total_revenue
    FROM sales.orders so
    JOIN sales.order_items soi
        ON so.order_id = soi.order_id
    GROUP BY so.customer_id
)
SELECT
    oc.customer_id,
    oc.order_count,
    cr.total_revenue
FROM OrderCounts oc
JOIN CustomerRevenue cr
    ON oc.customer_id = cr.customer_id;


-- 6.4

WITH Numbers AS (
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM Numbers
    WHERE n < 10
)
SELECT
    n,
    n * n AS square
FROM Numbers
OPTION (MAXRECURSION 10);


-- 6.5

WITH OrgChart AS (
    SELECT
        s.staff_id,
        s.first_name,
        s.manager_id,
        CAST(NULL AS VARCHAR(100)) AS manager_first_name,
        0 AS level
    FROM sales.staffs s
    WHERE s.manager_id IS NULL

    UNION ALL

    SELECT
        s.staff_id,
        s.first_name,
        s.manager_id,
        oc.first_name AS manager_first_name,
        oc.level + 1 AS level
    FROM sales.staffs s
    JOIN OrgChart oc
        ON s.manager_id = oc.staff_id
)
SELECT
    staff_id,
    first_name,
    manager_first_name,
    level
FROM OrgChart
ORDER BY level, staff_id;


-- 6.6
-- No, the claim is not accurate. CTEs are not automatically faster than subqueries.
-- If the result must be calculated once and reused, use a temporary table.
```