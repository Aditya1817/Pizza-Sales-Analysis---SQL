-- Retrieve the total number of orders placed.
select count(distinct order_id) as total_orders_placed
from orders;


-- Calculate the total revenue generated from pizza sales.
select round(sum(quantity*price), 2) as total_revenue
from order_details od
join pizzas p
on p.pizza_id = od.pizza_id;


-- Identify the highest-priced pizza.
select name, price
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
order by price desc
limit 1;


-- Identify the most common pizza size ordered.
select size, sum(quantity) qty
from pizzas p
join order_details od
on p.pizza_id = od.pizza_id
group by size
order by qty desc;


-- List the top 5 most ordered pizza types along with their quantities.
select name, sum(quantity) as qty
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on od.pizza_id = p.pizza_id
group by name
limit 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
select category, sum(quantity) as total_orders
from order_details od 
join pizzas p
on p.pizza_id = od.pizza_id
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by category
order by total_orders desc;


-- Determine the distribution of orders by hour of the day.
select hour(order_time) hr, count(*) as orders
from orders
group by hr
order by hr asc;


-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(distinct name) as no_of_pizzas
from pizza_types
group by category
order by no_of_pizzas desc;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(tot)) as avg_pizzas_ordered_per_day
from
(select order_date, sum(quantity) as tot
from orders o
join order_details od
on o.order_id = od.order_id
group by order_date)a;


-- Determine the top 3 most ordered pizza types based on revenue.
select name, sum(quantity*price) as revenue
from pizzas p join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
join order_details od
on od.pizza_id = p.pizza_id
group by name
order by revenue desc
limit 3;


-- Calculate the percentage contribution of each pizza category to total revenue.
with cte as
(select category, round(sum(quantity*price), 2) as revenue
from pizzas p join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
join order_details od 
on od.pizza_id = p.pizza_id
group by category)

select category, round(100*revenue/sum(revenue) over(), 2) as perc
from cte
order by perc desc;


-- Analyze the cumulative revenue generated over time.
-- Sol 1
select order_date, order_time, price, quantity,
sum(quantity*price) over(order by order_date asc, order_time) as cum_rev
from orders o join order_details od
on o.order_id = od.order_id
join pizzas p
on p.pizza_id = od.pizza_id;

-- Sol 2
with cte as
(select order_date, order_time, sum(quantity*price) as rev
from orders o join order_details od
on o.order_id = od.order_id
join pizzas p
on p.pizza_id = od.pizza_id
group by order_date, order_time)

select *, sum(rev) over(order by order_date, order_time) as cum_rev
from cte;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with cte as 
(select category, name,
round(sum(price*quantity)) as revenue
from pizzas p join order_details od
on p.pizza_id = od.pizza_id
join pizza_types pt
on pt.pizza_type_id = p.pizza_type_id
group by category, name),

cte2 as
(select *,
dense_rank() over(partition by category order by revenue desc) as dnk
from cte)

select category, name, revenue from cte2 where dnk <= 3;