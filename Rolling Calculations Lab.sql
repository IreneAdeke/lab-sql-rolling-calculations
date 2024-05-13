use sakila; 
# 1. Get the number of monthly active customers. 

select * from sakila.rental;

drop view if exists customer_activity; 

create or replace view customer_activity as
select
	date_format(convert(rental_date,date), '%m') as month_number,
    date_format(convert(rental_date,date), '%M') as month,
	count(customer_id) as active_customers
from sakila.rental
group by month_number, month
order by month_number;

select * from sakila.customer_activity;	

# 2. Active users in the previous month.

drop view if exists customer_activity_previous_month; 

create or replace view customer_activity_previous_month as
select 
	month_number,
	month,
    lag(active_customers, 1) over (order by month_number) as active_customers_previous_month,
    active_customers
from sakila.customer_activity
group by month_number, month
order by month_number;

select * from sakila.customer_activity_previous_month;

# 3. Percentage change in the number of active customers.

drop view if exists customer_activity_percentage; 

create or replace view customer_activity_percentage as
with cte_percentage as(
select
	month_number,
	month,
	active_customers_previous_month,
    active_customers
from sakila.customer_activity_previous_month
)
select 
	*,
    round(((active_customers-active_customers_previous_month)/active_customers_previous_month)*100, 1) as percentage
from cte_percentage;

select * from sakila.customer_activity_percentage;

# 4. Retained customers every month.

select * from sakila.rental;

with retained_customers as (
select
	date_format(convert(rental_date,date), '%Y') as activity_year, 
	date_format(convert(rental_date,date), '%M') as activity_month,
    date_format(convert(rental_date,date), '%m') as activity_month_number,
	count(distinct customer_id) as unique_customers
  from sakila.rental 
  group by activity_year, activity_month, activity_month_number
)    
select activity_year,
       activity_month,
       lag(unique_customers, 1) over(order by activity_month_number) as unique_customers_previous_month,
       unique_customers
from retained_customers;
