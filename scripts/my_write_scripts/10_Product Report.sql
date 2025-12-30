/*
======================================================================================================
Product Report 
=======================================================================================================
Purpose :
	- This report consolidates key customer metrics and behaviors.
Highlights:
	1.Gathers essential fields such as product name, category, subcategory, and cost.
	2.Segments products by revenue to identify High-Performers, Mid-Range, or Low-performers.
	3.Aggtegates Product-level metrics:
		-total orders 
		-total sales 
		-total Quantity sold 
		- total customers(unique)
		-Lifespan (in months)
	4.Calculates caluable KPIs:
		-recency (months since last sales ) 
		- average order revenue(AOR)
		- average monthly Revenue
=======================================================================================================
*/
CREATE VIEW gold.repot_products AS
WITH base_query AS (
/*------------------------------------------------------------------------
1) Base Query: retriwves core columns from fact sales and dim_products
------------------------------------------------------------------------*/
	SELECT 
		f.order_number, 
		f.order_date,
		f.customer_key,
		f.sales_amount,
		f.quanity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p 
		ON f.product_key = p.product_key
	WHERE order_date IS NOT NULL --only consider valid sales dates
),

product_aggregations AS (
--2) Product Aggregation : Summarizes key metrics at the product level
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sales_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM (quanity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quanity,0)),1) AS avg_selling_price
FROM base_query
GROUP BY 
	product_key,
	product_name,
	category,
	subcategory,
	cost
)

/*---------------------------------------------------------------------------------------
3) Final Query L combines all product results into one output
----------------------------------------------------------------------------------------*/
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sales_date,
	DATEDIFF(MONTH,last_sales_date, GETDATE()) AS recency_in_months,
	CASE WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	--Average Order Revenue (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0 
		ELSE total_sales /total_orders
	END AS avg_order_revenue,
	
	--Average Monthly Revenue
	CASE 
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue
FROM product_aggregations