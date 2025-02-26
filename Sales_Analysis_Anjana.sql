#Retrieve the total number of orders placed.
use pizzahut;
Select Count(order_id) as Total_Orders from orders;

#Calculate the total revenue generated from pizza sales.
SELECT 
Sum(order_details.quantity*pizzas.price) as Total_revenue 
FROM pizzahut.order_details  
join pizzas 
on order_details.pizza_id = pizzas.pizza_id;

# Identify the highest-priced pizza.
use pizzahut;
Select pizza_types.name, Pizzas.size, Pizzas.price 
from  pizzas join pizza_types 
on pizzas.pizza_type_id = pizza_types.pizza_type_id 
where price = (Select max(price) from Pizzas);
#OR
Select pizza_types.name, Pizzas.size, Pizzas.price 
from  pizzas join pizza_types 
on pizzas.pizza_type_id = pizza_types.pizza_type_id 
order by Pizzas.price desc limit 1;

#Identify the most common pizza size ordered.
Select size, count(size) as order_count 
from Order_details join pizzas 
on order_details.pizza_id = pizzas.pizza_id 
group by pizzas.size order by count(size) desc limit 1 ;

#List the top 5 most ordered pizza types along with their quantities.
Select  pizza_types.name,sum(order_details.quantity) as 'Quantity'
from order_details join pizzas 
on  order_details.pizza_id= pizzas.pizza_id
join pizza_types
on  pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name order by sum(order_details.quantity) desc limit 5; 

#Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types. category, sum(order_details.quantity)FROM order_details 
join pizzas 
on order_details.Pizza_id=pizzas.pizza_id
join pizza_types
on pizzas.pizza_type_id=pizza_types.pizza_type_id group by category order by sum(order_details.quantity) asc;

# Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS 'hour',
    COUNT(order_id) AS 'No.of Orders'
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time) ASC;

#Join relevant tables to find the category-wise distribution of pizzas.
Select category,count(name) from pizza_types group by category;

#Determine the top 3 most ordered pizza types based on revenue.
Select  name,pizzas.pizza_type_id, sum(quantity*price) as 'revenue' from order_details 
join pizzas on order_details.Pizza_id=pizzas.pizza_id 
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_type_id order by sum(quantity*price) desc limit 3;

#Advanced:
# Calculate the percentage contribution of each pizza type/name to total revenue.
   ### revenue per order
Select Pizza_type_id,(quantity*price) as 'revenue' from order_details 
join pizzas 
on pizzas.pizza_id = order_details.pizza_id ;
  ### total reveune
select sum(revenue) from (Select Pizza_type_id,(quantity*price) as 'revenue' from order_details 
join pizzas 
on pizzas.pizza_id = order_details.pizza_id ) as revunue_table;
  ### percentage contribution of each pizza type 
Select Pizza_type_id,sum(quantity*price*100)/(select sum(revenue) from (Select Pizza_type_id,(quantity*price) as 'revenue' from order_details 
join pizzas 
on pizzas.pizza_id = order_details.pizza_id ) as revunue_table) as 'revenue' from order_details 
join pizzas 
on pizzas.pizza_id = order_details.pizza_id group by pizza_type_id ;
   ### checking if the above code actually gave percentages - sum should be 100
select  sum(revenue) from (Select Pizza_type_id,sum(quantity*price*100)/(select sum(revenue) from (Select Pizza_type_id,(quantity*price) as 'revenue' from order_details 
join pizzas 
on pizzas.pizza_id = order_details.pizza_id ) as revunue_table) as 'revenue' from order_details 
join pizzas 
on pizzas.pizza_id = order_details.pizza_id group by pizza_type_id) as rev_tab;

# Calculate the percentage contribution of each pizza category to total revenue.
Select category, round(sum(quantity* price*100)/(select sum(revenue) from (Select Pizza_type_id,(quantity*price) as 'revenue' from order_details 
join pizzas 
on pizzas.pizza_id = order_details.pizza_id ) as revunue_table),2) as Revenue_percentage from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id group by category;

# Analyze the cumulative revenue generated over time.
  ##find daily revenue first
Select order_date, Round(sum(quantity*price),2) as day_revenue from orders
join order_details
on orders.order_id = order_details.order_id
join pizzas
on pizzas.pizza_id = order_details.pizza_id
group by Order_date;

Select order_date, day_revenue, sum(day_revenue) over (order by order_date) as cummulative_revenue from (Select order_date, Round(sum(quantity*price),2) as day_revenue from orders
join order_details
on orders.order_id = order_details.order_id
join pizzas
on pizzas.pizza_id = order_details.pizza_id
group by Order_date) as Sales_per_day_table;

#Determine the top 3 most ordered pizza types based on revenue for each pizza category.
  ###Ranks of pizza types based on revenue for each pizza category.
select category, name, revenue, (rank() over (partition by category order by revenue desc)) as 'Rank' from (Select category, name, round(sum(price*quantity),2) as 'revenue' from order_details
join pizzas
on pizzas.pizza_id = order_details.Pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by category,name
order by category asc) as rev_tab;
   ### Now determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue, ranks from (select category, name, revenue, (rank() over (partition by category order by revenue desc)) as 'Ranks' from (Select category, name, round(sum(price*quantity),2) as 'revenue' from order_details
join pizzas
on pizzas.pizza_id = order_details.Pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by category,name
order by category asc) as rev_tab) as b
where ranks <= 3;