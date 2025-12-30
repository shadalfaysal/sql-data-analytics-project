
--calculate the total sales per month and the running total of  sales over time .

select 
order_date, 
total_sales,
--window function 
sum(total_sales) over (partition by order_date order by order_date) as running_total_sales
from (

select 
datetrunc(month,order_date) as order_date,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null 
group by datetrunc(month,order_date)

)t 


--by year 

select 
order_date, 
total_sales,
--window function 
sum(total_sales) over ( order by order_date) as running_total_sales
from (
select 
datetrunc(YEAR,order_date) as order_date,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null 
group by datetrunc(YEAR,order_date)

)t 


-- and the running total of sales over time 

select 
order_date, 
total_sales,
sum(total_sales) over (partition by order_date order by order_date) as running_total_sales,
avg(avg_price) over ( order by order_date) as moving_avg
from 
(
	select 
	datetrunc(month,order_date) as order_date,
	sum(sales_amount) as total_sales,
	AVG(price) as avg_price
	from gold.fact_sales
	where order_date is not null 
	group by datetrunc(month,order_date), order_date

)t 