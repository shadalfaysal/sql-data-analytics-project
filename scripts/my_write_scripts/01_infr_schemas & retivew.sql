
 --explore all objects in the database 
  select 
  * 
  from INFORMATION_SCHEMA.TABLES;

  --explore all columns in the database
  select * from INFORMATION_SCHEMA.COLUMNS
  where TABLE_NAME= 'dim_customer'


/*  
               Dimension 
*/
-- explore all countries our customers come from 
 select distinct country from gold.dim_customers

 --expl: all categories 'the major divisions'
 select distinct category, subcategory,product_name from gold.dim_products
 order by 1,2,3

 --find the date of the first and last order 
 select 
 min(order_date) first_order_date,
 max(order_date) last_order_date,
 datediff(MONTH,min(order_date),max(order_date)) as range_of_month
 from gold.fact_sales

 -- find the youngest and oldest customers
 select
  min(birthdate) as oldest_birthdate,
    datediff(YEAR,min(birthdate),GETDATE()) as oldest_age,
  max(birthdate) as letest_birthdate,
  datediff(YEAR,max(birthdate),GETDATE()) as latest_age,
  datediff(YEAR,min(birthdate),max(birthdate)) as range_of_year
  from gold.dim_customers

  --find the total sales
  select sum(sales_amount) as total_sales from gold.fact_sales

  --find how many items are sold 
 select sum(quanity) as total_quantity from gold.fact_sales

  -- find the average selling price 
   select AVG(price) as avg_price from gold.fact_sales

-- find the total number of orders 
 select count(order_number) as total_num_order from gold.fact_sales
 select count(distinct order_number) as total_num_order from gold.fact_sales

--find the total number of products
select count ( product_key) as total_product from gold.dim_products
select count (distinct product_key) as total_product from gold.dim_products

--find the total number of customers 
select count(customer_key) from gold.dim_customers

--find the total number of customers that has place on order 
select count(customer_key) from gold.fact_sales
select count( distinct customer_key) from gold.fact_sales
