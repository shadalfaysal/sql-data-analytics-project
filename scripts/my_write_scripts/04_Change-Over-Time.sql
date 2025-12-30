
select 
Year(order_date) as order_year,
MONTH (order_date) as order_month,
sum(sales_amount)as total_sales,
count(distinct customer_key) as total_customres,
sum(quanity) as total_quantity
from gold.fact_sales
where order_date is not null 
group by Year(order_date),MONTH (order_date)
order by Year(order_date), MONTH (order_date)

--datetrunc function 
select 
DATETRUNC(MONTH, order_date) as order_DATE,
sum(sales_amount)as total_sales,
count(distinct customer_key) as total_customres,
sum(quanity) as total_quantity
from gold.fact_sales
where order_date is not null 
group by DATETRUNC(MONTH, order_date)
order by DATETRUNC(MONTH, order_date)


--formate function ata te short kora jay na 
select 
FORMAT( order_date , 'yyyy-MMM') as order_DATE,
sum(sales_amount)as total_sales,
count(distinct customer_key) as total_customres,
sum(quanity) as total_quantity
from gold.fact_sales
where order_date is not null 
group by FORMAT( order_date , 'yyyy-MMM')
order by FORMAT( order_date , 'yyyy-MMM')
