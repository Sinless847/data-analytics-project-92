-- top_10_popular_products.csv
SELECT
    p.product_name,
    COUNT(s.sales_id) AS operations
FROM
    sales AS s
    JOIN products AS p
        ON s.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    operations DESC
LIMIT 10;


-- top_10_profitable_products.csv
SELECT
    p.product_name,
    SUM(s.quantity * p.price) AS income
FROM
    sales AS s
    JOIN products AS p
        ON s.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    income DESC
LIMIT 10;


-- customers_count.csv
SELECT
    COUNT(DISTINCT c.customer_id) AS customers_count
FROM
    customers AS c;


-- top_10_total_income.csv
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    sales AS s
    JOIN employees AS e
        ON s.sales_person_id = e.employee_id
    JOIN products AS p
        ON s.product_id = p.product_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name
ORDER BY
    income DESC
LIMIT 10;


-- lowest_average_income.csv
WITH seller_avg AS (
    SELECT
        e.employee_id,
        e.first_name || ' ' || e.last_name AS seller,
        AVG(s.quantity * p.price) AS avg_income_per_sale
    FROM
        sales AS s
        JOIN employees AS e
            ON s.sales_person_id = e.employee_id
        JOIN products AS p
            ON s.product_id = p.product_id
    GROUP BY
        e.employee_id,
        e.first_name,
        e.last_name
)
SELECT
    seller,
    avg_income_per_sale
FROM
    seller_avg
ORDER BY
    avg_income_per_sale
LIMIT 10;


-- day_of_the_week_income.csv
SELECT
    EXTRACT(DOW FROM s.sale_date) AS day_of_week,
    SUM(s.quantity * p.price) AS total_income
FROM
    sales AS s
    JOIN products AS p
        ON s.product_id = p.product_id
GROUP BY
    day_of_week
ORDER BY
    total_income DESC;


-- age_groups.csv
SELECT
    CASE
        WHEN c.age < 20 THEN 'under_20'
        WHEN c.age BETWEEN 20 AND 29 THEN '20_29'
        WHEN c.age BETWEEN 30 AND 39 THEN '30_39'
        ELSE '40_and_over'
    END AS age_group,
    COUNT(c.customer_id) AS customers_count
FROM
    customers AS c
GROUP BY
    age_group
ORDER BY
    age_group;


-- customers_by_month.csv
SELECT
    EXTRACT(MONTH FROM c.registered_at) AS month,
    COUNT(c.customer_id) AS customers_count
FROM
    customers AS c
GROUP BY
    month
ORDER BY
    month;


-- special_offer.csv
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer,
    SUM(s.quantity * p.price) AS total_income
FROM
    sales AS s
    JOIN customers AS c
        ON s.customer_id = c.customer_id
    JOIN products AS p
        ON s.product_id = p.product_id
WHERE
    s.sale_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY
    total_income DESC
LIMIT 10;
