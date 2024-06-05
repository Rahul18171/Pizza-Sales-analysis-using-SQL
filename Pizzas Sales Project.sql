-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders;
    
    
-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    

-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY 2 DESC
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS Count_orders
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- List the top 5 most ordered pizza types 
-- along with their quantities.

SELECT 
    pt.name, 
SUM(od.quantity) AS Quantity
FROM
    pizza_types as pt
        JOIN
    pizzas as p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details as od ON od.pizza_id = p.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- Join the necessary tables to find the 
-- total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(od.quantity) AS Quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY 1
ORDER BY 2 DESC;


-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS Order_count
FROM
    orders
GROUP BY 1;


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average 
-- number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) as Avg_pizza_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders AS o
    JOIN order_details AS od ON o.order_id = od.order_id
    GROUP BY 1) AS order_qty;
    
    
  -- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, ROUND(SUM(od.quantity * p.price), 2) AS Revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) 
                FROM
                    order_details AS od
                        JOIN
                    pizzas AS p ON od.pizza_id = p.pizza_id) * 100,2) AS Revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY 1
ORDER BY 2 DESC;  


-- Analyze the cumulative revenue generated over time.

select order_date,Revenue,
       round(sum(Revenue) over(order by order_date),2) as Cum_Revenue
from       
		(select o.order_date,
		round(sum(od.quantity*p.price),2) as Revenue
		from order_details as od
		join pizzas as p
		on od.pizza_id=p.pizza_id
		join orders as o
		on o.order_id=od.order_id
		group by 1) as Sales;
        
        
-- Determine the top 3 most ordered pizza types 
-- based on revenue for each pizza category.

select name,Revenue,category from
(select category,name,Revenue,
rank() over(partition by category order by Revenue desc) as rn
from
(select pt.category,pt.name,
sum(od.quantity*p.price) as Revenue
from pizza_types as pt
join pizzas as p
on p.pizza_type_id=pt.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by 1,2) as a) as b
where rn<=3
group by 1,2,3;
