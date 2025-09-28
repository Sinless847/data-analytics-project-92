-- top_10_profitable_products.csv
SELECT COUNT(*) AS customers_count
FROM
    customers;
--top_10_total_income.csv
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN employees AS e
    ON s.sales_person_id = e.employee_id
INNER JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY income DESC
LIMIT 10;
--day_of_the_week_income.csv
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    TO_CHAR(s.sale_date, 'FMday') AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN employees AS e
    ON s.sales_person_id = e.employee_id
INNER JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.employee_id,
    TO_CHAR(s.sale_date, 'FMday'),
    TO_CHAR(s.sale_date, 'ID')
ORDER BY TO_CHAR(s.sale_date, 'ID')::int, seller;
--age_groups.csv
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END;
--customers_by_month.csv
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY selling_month;
--special_offer.csv
WITH first_sales AS (
    SELECT
        s.customer_id,
        s.sale_date,
        s.sales_person_id,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.sale_date, s.sales_id
        ) AS rn
    FROM sales AS s
    INNER JOIN products AS p ON s.product_id = p.product_id
    WHERE p.price = 0
)

SELECT
    fs.sale_date,
    c.first_name || ' ' || c.last_name AS customer,
    e.first_name || ' ' || e.last_name AS seller
FROM first_sales AS fs
INNER JOIN customers AS c ON fs.customer_id = c.customer_id
INNER JOIN employees AS e ON fs.sales_person_id = e.employee_id
WHERE fs.rn = 1
ORDER BY c.customer_id;
--lowest_average_income.csv
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    ROUND(AVG(p.price * s.quantity)) AS average_income
FROM sales AS s
INNER JOIN employees AS e
    ON s.sales_person_id = e.employee_id
INNER JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING
    AVG(p.price * s.quantity) < (
        SELECT AVG(p2.price * s2.quantity)
        FROM sales AS s2
        INNER JOIN products AS p2
            ON s2.product_id = p2.product_id
    )
ORDER BY average_income ASC;
