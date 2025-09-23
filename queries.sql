--Напишите запрос, который считает общее количество покупателей из таблицы customers.
SELECT COUNT(*) AS customers_count --подсчитывает общее количество записей в таблице customers и выводит это число с псевдонимом customers_count
FROM customers;

--top_10_total_income.csv
SELECT 
    e.first_name || ' ' || e.last_name AS seller, --объединяю имя и фамилию сотрудника в одно поле и даю псевданим
    COUNT(s.sales_id) AS operations,--считаю кол-во сделок
    FLOOR(SUM(s.quantity * p.price)) AS income--считаю доход
FROM sales s
JOIN employees e --джойним таблицы
  ON s.sales_person_id = e.employee_id
JOIN products p 
  ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name --проводим группировку
ORDER BY income DESC--проводим сортировку по убыванию дохода
LIMIT 10;--берем только 10 лучших продавцов

--lowest_average_income.csv
WITH seller_stats AS (--пишем подзапрос что бы посчитать статистику каждого продавца
    SELECT 
        e.first_name || ' ' || e.last_name AS seller,
        SUM(s.quantity * p.price) AS total_income,
        COUNT(s.sales_id) AS operations,
        SUM(s.quantity * p.price) / COUNT(s.sales_id) AS avg_income_per_sale
    FROM sales s
    JOIN employees e ON s.sales_person_id = e.employee_id
    JOIN products p ON s.product_id = p.product_id
    GROUP BY e.employee_id, e.first_name, e.last_name
),
overall_avg AS (--пишем подзапрос что бы подсчитать средний доход
    SELECT SUM(total_income)::numeric / SUM(operations) AS overall_avg_income
    FROM seller_stats
)
SELECT 
    seller,
    FLOOR(avg_income_per_sale) AS average_income
FROM seller_stats, overall_avg
WHERE avg_income_per_sale < overall_avg_income--ставим фильтр что бы выбрать только тех продавцов у которых средний доход с сделки ниже среднего по компании
ORDER BY average_income ASC;--проводим сортировку по возрастанию

--day_of_the_week_income.csv
SELECT 
    e.first_name || ' ' || e.last_name AS seller,--объединяю имя и фамилию сотрудника в одно поле
    TO_CHAR(s.sale_date, 'FMday') AS day_of_week,--преобразуем дату в название дня недели
    FLOOR(SUM(s.quantity * p.price)) AS income--считаем доход и округляем в меньшую сторону
FROM sales s
JOIN employees e --джойним таблицы
    ON s.sales_person_id = e.employee_id
JOIN products p 
    ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name, TO_CHAR(s.sale_date, 'FMday'), TO_CHAR(s.sale_date, 'ID')--проводим группировку
ORDER BY TO_CHAR(s.sale_date, 'ID')::int, seller;--проводим сортировку по дню недели,а затем по имени

--age_groups.csv
WITH age_groups AS (--создаем таблицу и присваиваем каждому клиенту категорию возраста
    SELECT
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            WHEN age > 40 THEN '40+'
        END AS age_category
    FROM customers
)
SELECT--считаем кол-во клиентов в каждой категории
    age_category,
    COUNT(*) AS age_count
FROM age_groups
GROUP BY age_category;--группируем по категориям

--customers_by_month.csv
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,--превращаем дату в формат год-месяц
    COUNT(DISTINCT s.customer_id) AS total_customers,--считаем уникальных клиентов совершивших покупку
    FLOOR(SUM(s.quantity * p.price)) AS income--считаем общий доход за месяц и производим округление в меньшую сторону
FROM sales s
JOIN products p ON s.product_id = p.product_id--джоиним таблицы
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')--группируем по дате
ORDER BY selling_month;--сортируем по дате, будет идти от более раннего месяца

--special_offer.csv
WITH first_sales AS (--формируем таблицу с первой бесплатной покупкой
    SELECT
        s.customer_id,
        s.sale_date,
        s.sales_person_id,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id 
            ORDER BY s.sale_date, s.sales_id
        ) AS rn
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    WHERE p.price = 0
)
SELECT
    c.first_name || ' ' || c.last_name AS customer,--объединяю имя и фамилию покупателя
    fs.sale_date,
    e.first_name || ' ' || e.last_name AS seller--объединяю имя и фамилию продавца
FROM first_sales fs
JOIN customers c ON fs.customer_id = c.customer_id
JOIN employees e ON fs.sales_person_id = e.employee_id
WHERE fs.rn = 1--берём только первую бесплатную покупку каждого клиента
ORDER BY c.customer_id;
