SELECT COUNT(*) AS customers_count --подсчитывает общее количество записей в таблице customers и выводит это число с псевдонимом customers_count--
FROM customers;

SELECT 
    e.first_name || ' ' || e.last_name AS seller, --объединяю имя и фамилию сотрудника в одно поле и даю псевданим--
    COUNT(s.sales_id) AS operations,--считаю кол-во сделок--
    FLOOR(SUM(s.quantity * p.price)) AS income--считаю доход--
FROM sales s
JOIN employees e --джойним таблицы--
  ON s.sales_person_id = e.employee_id
JOIN products p 
  ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name --проводим группировку--
ORDER BY income DESC--проводим сортировку по убыванию дохода--
LIMIT 10;--берем только 10 лучших продавцов--

WITH seller_stats AS (--пишем подзапрос что бы посчитать статистику каждого продавца--
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
overall_avg AS (--пишем подзапрос что бы подсчитать средний доход на компанию--
    SELECT SUM(total_income)::numeric / SUM(operations) AS overall_avg_income
    FROM seller_stats
)
SELECT 
    seller,
    FLOOR(avg_income_per_sale) AS average_income
FROM seller_stats, overall_avg
WHERE avg_income_per_sale < overall_avg_income--ставим фильтр что бы выбрать только тех продавцов у которых средний доход с сделки ниже среднего по компании--
ORDER BY average_income ASC;--проводим сортировку по возрастанию--


SELECT 
    e.first_name || ' ' || e.last_name AS seller,--объединяю имя и фамилию сотрудника в одно поле--
    TO_CHAR(s.sale_date, 'Day') AS day_of_week,--преобразуем дату в название дня недели--
    FLOOR(SUM(s.quantity * p.price)) AS income--считаем доход и округляем в меньшую сторону--
FROM sales s
JOIN employees e --джойним таблицы--
  ON s.sales_person_id = e.employee_id
JOIN products p 
  ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name, TO_CHAR(s.sale_date, 'Day'), EXTRACT(DOW FROM s.sale_date)--проводим группировку--
ORDER BY EXTRACT(DOW FROM s.sale_date), seller;--проводим сортировку по дню недели,а затем по имени--
