
\Data Cleaning\

--1. checking for duplicates
-----checking for duplicates in accounts table
select id, count(id) as count
from accounts
group by id
having count(id) > 1;

-----checking for duplicates in orders table
select id, count(id) as count
from orders
group by id
having count(id) > 1;

----checking for duplicates in region table
select id, count(id) as count
from region
group by id
having count(id) > 1;

----checking for duplicates in sales_reps table
select id, count(id) as count
from sales_reps
group by id
having count(id) > 1;

----checking for duplicate in web_events table
select id, count(id) as count
from web_events
group by id
having count(id) > 1;


--2. Checking for null values
----checking for null values in accounts table
select * from accounts 
where id is null or name is null or website is null 
or lat is null or long is null or primary_poc is null or sales_rep_id is null;

----checking for null values in orders table
select * from orders
where id is null or account_id is null or occurred_at is null or standard_qty is null
or gloss_qty is null or poster_qty is null or total is null or standard_amt_usd is null
or gloss_amt_usd is null or poster_amt_usd is null or total_amt_usd is null;

----checking for null values in region table
select * from region
where id is null or name is null;

----checking for null values in sales_reps table
select * from sales_reps
where id is null or name is null or region_id is null;

----checking for null values in web_events table
select * from web_events
where id is null, account_id is null, occurred_at is null, channel is null;


--3. Creating new columns for year, month, day from the occurred_at column in the orders table
Alter table orders
add column year numeric,
add column month numeric,
add column day_of_week numeric;

update orders
set
    year = extract(year from occurred_at)::numeric,
    month = extract(month from occurred_at)::numeric,
    day_of_week = extract(isodow from occurred_at)::numeric;
	
UPDATE orders
SET
   day_of_week_text = CASE
       WHEN day_of_week = 0 THEN 'Sunday'
       WHEN day_of_week = 1 THEN 'Monday'
       WHEN day_of_week = 2 THEN 'Tuesday'
       WHEN day_of_week = 3 THEN 'Wednesday'
       WHEN day_of_week = 4 THEN 'Thursday'
       WHEN day_of_week = 5 THEN 'Friday'
       WHEN day_of_week = 6 THEN 'Saturday' 
   END,
   
   month_text = CASE
       WHEN month = 1 THEN 'January'
       WHEN month = 2 THEN 'February'
       WHEN month = 3 THEN 'March'
       WHEN month = 4 THEN 'April'
       WHEN month = 5 THEN 'May'
       WHEN month = 6 THEN 'June'
       WHEN month = 7 THEN 'July'
       WHEN month = 8 THEN 'August'
       WHEN month = 9 THEN 'September'
       WHEN month = 10 THEN 'October'
       WHEN month = 11 THEN 'November'
       WHEN month = 12 THEN 'December'
    END;

\Data Exploration\

--1. How many customers does parch and posey have?
select count (distinct id) as total_customers
from accounts

--2. How much revenue has parch and posey made?
select sum(total_amt_usd) as total_sales
from orders

--3. What quantity of orders has parch and posey made?
select sum(total) as total_orders
from orders

--4. What is the revenue for each product?
SELECT
SUM(gloss_amt_usd) AS gloss,
SUM(poster_amt_usd) AS poster,
SUM(standard_amt_usd) AS standard
FROM orders;

--5. What is the quantity of total orders per product?
SELECT
SUM(gloss_qty) as gloss,
SUM(poster_qty) as poster,
SUM(standard_qty) as standard,
FROM orders;

--6. How much has Parch and Posey made between 2013–2017?
SELECT
    year,
    SUM(total_amt_usd) AS total_sales
FROM orders
GROUP BY year
ORDER BY total_sales desc;

--7. what is the most profitable quarter for parch and posey?
SELECT
  CASE
    WHEN "month" LIKE '%January%' OR "month" LIKE '%February%' OR "month" LIKE '%March%' THEN 'Q1'
    WHEN "month" LIKE '%April%' OR "month" LIKE '%May%' OR "month" LIKE '%June%' THEN 'Q2'
    WHEN "month" LIKE '%July%' OR "month" LIKE '%August%' OR "month" LIKE '%September%' THEN 'Q3'
    WHEN "month" LIKE '%October%' OR "month" LIKE '%November%' OR "month" LIKE '%December%' THEN 'Q4'
    ELSE 'Unknown'
  END AS Quarter,
  SUM("total_amt_usd") as total_sales
FROM orders
GROUP BY Quarter
ORDER BY Quarter;

--8. What is the most profitable region for parch and posey?
SELECT r.name AS region_name, ceil(sum(o.total_amt_usd)) as total_sales
FROM region r
JOIN sales_reps sr ON r.id = sr.region_id
JOIN accounts a ON sr.id = a.sales_rep_id
JOIN orders o ON a.id = o.account_id
GROUP BY r.name
ORDER BY total_sales DESC

--9. what channel of recruiting customers yields the most results?
SELECT channel, count(*) as customers
from web_events
group by channel
order by count(channel) desc








