Create database pizza_sales;

Use pizza_sales;

SET autocommit=0;

CREATE TABLE order_details (
    order_details_id INT,
    order_id INT,
    pizza_id VARCHAR(50),
    quantity INT
);

Select*from order_details;
SHOW VARIABLES LIKE "secure_file_priv";

SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_details_id, order_id, pizza_id, quantity);

SELECT COUNT(*) FROM order_details;

select * from order_details;

Create table orders(
order_id int primary key,
date Date,
time Time
);

TRUNCATE TABLE orders;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
IGNORE
INTO TABLE orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, @date, time)
SET date = STR_TO_DATE(@date, '%d-%m-%Y');

Select*from orders;
select*from order_details;
select*from Pizza_types;
Select*from pizzas;



-- Q1: Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS total_orders FROM orders;

-- Q2: Calculate the total revenue generated from pizza sales.

SELECT SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- Q3: Identify the highest-priced pizza.

SELECT pizza_id, price FROM pizzas
ORDER BY price DESC LIMIT 1;

-- Q4: Identify the most common pizza size ordered.

SELECT p.size, COUNT(*) AS total_orders FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size 
ORDER BY total_orders DESC LIMIT 1;

-- Q5: List the top 5 most ordered pizza types along with their quantities.

SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC LIMIT 5;

-- Q6: Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- Q7: Determine the distribution of orders by hour of the day.

SELECT HOUR(time) AS order_hour, COUNT(*) AS total_orders
FROM orders
GROUP BY order_hour
ORDER BY order_hour;

-- Q8: Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, COUNT(*) AS total_pizzas
FROM pizza_types
GROUP BY category;

-- Q9: Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT AVG(daily_total) AS avg_pizzas_per_day
FROM (
    SELECT o.date, SUM(od.quantity) AS daily_total
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.date
) t;

-- Q10: Determine the top 3 most ordered pizza types based on revenue

SELECT pt.name, SUM(od.quantity * p.price) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC LIMIT 3;

-- Q11: Calculate the percentage contribution of each pizza type to total revenue.

Select pt.name,
		Sum(p.price * od.quantity) As revenue,
        Sum(p.price * od.quantity) * 100.0
        /sum(sum(p.price * od.quantity)) over () As percentage
From order_details od
Join pizzas p on od.pizza_id = p.pizza_id
Join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
Group by pt.name;

-- Q12: Analyze the cumulative revenue generated over time.

SELECT o.date,
       SUM(od.quantity * p.price) AS daily_revenue,
       SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.date) AS cumulative_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.date;

-- Q13: Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT * FROM (
    SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS revenue,
           RANK() OVER (
               PARTITION BY pt.category 
               ORDER BY SUM(od.quantity * p.price) DESC
           ) AS rnk
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) t WHERE rnk <= 3;