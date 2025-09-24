-- Общее количество покупателей
SELECT
    COUNT(*) AS customers_count
FROM
    customers;


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
WITH seller_stats AS (
    SELECT
        e.first_name || ' ' || e.last_name AS seller,
        SUM(s.quantity * p.price) AS total_income,
        COUNT(s.sales_id) AS operations,
        SUM(s.quantity * p.price) / COUNT(s.sales_id) AS avg_income_per_sale
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
),

overall_avg AS (
    SELECT
        SUM(seller_stats.total_income)::numeric / SUM(seller_stats.operations)
        AS overall_avg_income
    FROM
        seller_stats
)

SELECT
    seller_stats.seller,
    FLOOR(seller_stats.avg_income_per_sale) AS average_income
FROM
    seller_stats
    CROSS JOIN overall_avg
WHERE
    seller_stats.avg_income_per_sale < overall_avg.overall_avg_income
ORDER BY
    average_income ASC;


-- day_of_the_week_income.csv
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    TO_CHAR(s.sale_date, 'FMday') AS day_of_week,
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
    e.last_name,
    TO_CHAR(s.sale_date, 'FMday'),
    TO_CHAR(s.sale_date, 'ID')
ORDER BY
    TO_CHAR(s.sale_date, 'ID')::int,
    seller;


-- age_groups.csv
WITH age_groups AS (
    SELECT
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            WHEN age > 40 THEN '40+'
        END AS age_category
    FROM
        customers
)

SELECT
    age_category,
    COUNT(*) AS age_count
FROM
    age_groups
GROUP BY
    age_category;


-- customers_by_month.csv
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    sales AS s
    JOIN products AS p
        ON s.product_id = p.product_id
GROUP BY
    TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY
    selling_month;


-- special_offer.csv
WITH first_sales AS (
    SELECT
        s.customer_id,
        s.sale_date,
        s.sales_person_id,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.sale_date, s.sales_id
        ) AS rn
    FROM
        sales AS s
        JOIN products AS p
            ON s.product_id = p.product_id
    WHERE
        p.price = 0
)

SELECT
    c.first_name || ' ' || c.last_name AS customer,
    fs.sale_date,
    e.first_name || ' ' || e.last_name AS seller
FROM
    first_sales AS fs
    JOIN customers AS c
        ON fs.customer_id = c.customer_id
    JOIN employees AS e
        ON fs.sales_person_id = e.employee_id
WHERE
    fs.rn = 1
ORDER BY
    c.customer_id;
