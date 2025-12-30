/*
Analyze the yearly performance of products by cumparing their sales 
to both the average sales performance of the product and the pervious year's sales
*/

with yearly_product_sales as (
	select 
		YEAR(f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS	current_sales
	from gold.fact_sales f
	left join gold.dim_products p 
	on f.product_key = p.product_key
	where f.order_date is not null
	group by 
	YEAR(f.order_date), p.product_name
) 
select 
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) over (partition by product_name ) as avg_sales,
	current_sales - AVG(current_sales) over (partition by product_name ) as diff_avg,
	case when current_sales - AVG(current_sales) over (partition by product_name )  > 0 then 'Above Avg'
		when current_sales - AVG(current_sales) over (partition by product_name )  < 0 then 'Below Avg'
		else 'avg'
	end avg_change,
	lag(current_sales) over (partition by product_name order by order_year) as py_sales,
	current_sales - lag(current_sales) over (partition by product_name order by order_year) as diff_py,
	case when current_sales - lag(current_sales) over (partition by product_name order by order_year)>0 then 'Above Avg'
		when current_sales - lag(current_sales) over (partition by product_name order by order_year) <0 then 'Below avg'
		else 'No Change '
	end py_change	
from yearly_product_sales
order by product_name, order_year