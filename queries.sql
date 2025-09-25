-- Общее количество покупателей
select
	COUNT(*) as customers_count
from
	customers as c;
-- top_10_total_income.csv
select
	e.first_name || ' ' || e.last_name as seller,
	COUNT(s.sales_id) as operations,
	FLOOR(SUM(s.quantity * p.price)) as income
from
	sales as s
join employees as e
        on
	s.sales_person_id = e.employee_id
join products as p
        on
	s.product_id = p.product_id
group by
	e.employee_id,
	e.first_name,
	e.last_name
order by
	income desc
limit 10;
-- lowest_average_income.csv
with seller_stats as (
select
	e.first_name || ' ' || e.last_name as seller,
	SUM(s.quantity * p.price) as total_income,
	COUNT(s.sales_id) as operations,
	SUM(s.quantity * p.price) / COUNT(s.sales_id) as avg_income_per_sale
from
	sales as s
join employees as e
            on
	s.sales_person_id = e.employee_id
join products as p
            on
	s.product_id = p.product_id
group by
	e.employee_id,
	e.first_name,
	e.last_name
),

overall_avg as (
select
	SUM(seller_stats.total_income)::numeric / SUM(seller_stats.operations) as overall_avg_income
from
	seller_stats
)

select
	seller_stats.seller,
	FLOOR(seller_stats.avg_income_per_sale) as average_income
from
	seller_stats
cross join overall_avg
where
	seller_stats.avg_income_per_sale < overall_avg.overall_avg_income
order by
	average_income asc;
-- day_of_the_week_income.csv
select
	e.first_name || ' ' || e.last_name as seller,
	TO_CHAR(s.sale_date, 'FMday') as day_of_week,
	FLOOR(SUM(s.quantity * p.price)) as income
from
	sales as s
join employees as e
        on
	s.sales_person_id = e.employee_id
join products as p
        on
	s.product_id = p.product_id
group by
	e.employee_id,
	e.first_name,
	e.last_name,
	TO_CHAR(s.sale_date, 'FMday'),
	TO_CHAR(s.sale_date, 'ID')
order by
	TO_CHAR(s.sale_date, 'ID')::int,
	seller;
-- age_groups.csv
with age_groups as (
select
	case
		when c.age between 16 and 25 then '16-25'
		when c.age between 26 and 40 then '26-40'
		when c.age > 40 then '40+'
	end as age_category
from
	customers as c
)

select
	age_category,
	COUNT(*) as age_count
from
	age_groups
group by
	age_category;
-- customers_by_month.csv
select
	TO_CHAR(s.sale_date, 'YYYY-MM') as selling_month,
	COUNT(distinct s.customer_id) as total_customers,
	FLOOR(SUM(s.quantity * p.price)) as income
from
	sales as s
join products as p
        on
	s.product_id = p.product_id
group by
	TO_CHAR(s.sale_date, 'YYYY-MM')
order by
	selling_month;
-- special_offer.csv
with first_sales as (
select
	s.customer_id,
	s.sale_date,
	s.sales_person_id,
	row_number() over (
            partition by s.customer_id
order by
	s.sale_date,
	s.sales_id
        ) as rn
from
	sales as s
join products as p
            on
	s.product_id = p.product_id
where
	p.price = 0
)

select
	c.first_name || ' ' || c.last_name as customer,
	fs.sale_date,
	e.first_name || ' ' || e.last_name as seller
from
	first_sales as fs
join customers as c
        on
	fs.customer_id = c.customer_id
join employees as e
        on
	fs.sales_person_id = e.employee_id
where
	fs.rn = 1
order by
	c.customer_id;
