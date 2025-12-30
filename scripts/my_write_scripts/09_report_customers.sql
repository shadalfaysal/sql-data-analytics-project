/*
======================================================================================================
Customer Report 
=======================================================================================================
Purpose :
	- This report consolidates key customer metrics and behaviors
Highlights:
	1.Gathers essential fields such as name , ages, and transaction details.
	2.Segments customers into categories (VIP, regular, New) and age groups.
	3.Aggtegates customer-level metrics:
		-total orders 
		-total sales 
		-total Quantity purchased 
		- total products
		-Lifespan (in months )
	4.Calculates caluable KPIs:
		-recency (months since last order ) 
		- average order value 
		- average monthly spend
=======================================================================================================
*/
CREATE VIEW gold.report_customers AS 
WITH base_query AS(
/*-----------------------------------------------------------------------------------------------------
1) base Query: Retieves core columns from tables
-------------------------------------------------------------------------------------------------------
*/
	select 
		f.order_number,
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quanity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ', c.last_name)as customer_name,
		DATEDIFF(YEAR, c.birthdate, GETDATE()) as age 
	from gold.fact_sales f
	left join gold.dim_customers c
	on c.customer_key = f.customer_key
	where order_date is not null
	)
, customer_aggregation as(
/*-----------------------------------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
-------------------------------------------------------------------------------------------------------*/
select
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) as total_orders,
		SUM(sales_amount) as total_sales,
		SUM(quanity) as total_quantity,
		COUNT(DISTINCT product_key) as total_products,
		MAX(order_date) as last_order_date,
		DATEDIFF(month, min (order_date), MAX (order_date)) as lifespan
from base_query
group by customer_key,
		customer_number,
		customer_name,
		age
)

select
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE 
		WHEN age <20  THEN 'Under 20'
		WHEN age between 20 and 29 THEN '20-29'
		WHEN age between 30 and 39 THEN '30-39'
		WHEN age between 40 and 49 THEN '40-49'
		ELSE '50 and above'
	END AS age_group,
	CASE 
		WHEN lifespan >= 12 and total_sales >5000 THEN 'VIP'
		WHEN lifespan >= 12 and total_sales <5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment,
	DATEDIFF(MONTH,last_order_date, GETDATE()) as recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	last_order_date,
	lifespan,
	--conpute averge order value (AVO)
	CASE WHEN total_orders = 0 THEN 0 
		ELSE total_sales/total_orders 
	END AS avg_order_value,
	--compute average monthly spend 
	CASE WHEN lifespan = 0 THEN total_sales
		ELSE total_sales/lifespan
	END AS avg_monthly_spend
from customer_aggregation