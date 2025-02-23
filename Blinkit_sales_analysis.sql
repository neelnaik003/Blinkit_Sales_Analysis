-- What is the total revenue generated from all sales?
Use blinkit_sales;
SELECT 
    SUM(a.price * b.quantity) AS total_revenue
FROM
    blinkit_products a
        JOIN
    blinkit_order_items b ON a.product_id = b.product_id;
    
-- What is the total revenue for each day?
SELECT 
    Date(blinkit_orders.order_date) AS order_day,
    SUM(blinkit_products.price * blinkit_order_items.quantity) AS total_revenue
FROM
    blinkit_orders
        JOIN
    blinkit_order_items ON blinkit_order_items.order_id = blinkit_orders.order_id
        JOIN
    blinkit_products ON blinkit_products.product_id = blinkit_order_items.product_id
GROUP BY order_day
LIMIT 10;

-- Which are the top 5 best-selling products by quantity sold?
SELECT 
    blinkit_products.product_name,
    SUM(blinkit_order_items.quantity) AS quantity_sold
FROM
    blinkit_products
        JOIN
    blinkit_order_items ON blinkit_products.product_id = blinkit_order_items.product_id
GROUP BY blinkit_products.product_name
order by quantity_sold desc
LIMIT 5;
 
 -- Which product categories contribute the most revenue?
SELECT 
    blinkit_products.category,
    SUM(blinkit_order_items.quantity * blinkit_order_items.unit_price) AS revenue
FROM
    blinkit_products
        JOIN
    blinkit_order_items ON blinkit_products.product_id = blinkit_order_items.product_id
GROUP BY blinkit_products.category
ORDER BY revenue DESC;

-- What are the peak sales hours based on order timestamps?
SELECT 
    HOUR(order_date), COUNT(order_id)
FROM
    blinkit_orders
GROUP BY HOUR(order_date);

-- What is the average delivery time delay?
SELECT 
    ROUND(AVG(TIMESTAMPDIFF(MINUTE,
                promised_delivery_time,
                actual_delivery_time)),
            2) AS avg_delivery_delay
FROM
    blinkit_orders;

-- Which top 5 cities or areas generate the highest revenue?
SELECT 
    blinkit_customer.area,
    SUM(blinkit_order_items.quantity * blinkit_order_items.unit_price) AS revenue
FROM
    blinkit_customer
        JOIN
    blinkit_orders ON blinkit_customer.customer_id = blinkit_orders.customer_id
        JOIN
    blinkit_order_items ON blinkit_order_items.order_id = blinkit_orders.order_id
GROUP BY blinkit_customer.area
ORDER BY revenue DESC
limit 5;

-- How many products were sold at a discount 
SELECT 
    sum(blinkit_order_items.quantity) as total_product_sold,
    ROUND(((blinkit_products.mrp - blinkit_order_items.unit_price) / (blinkit_products.mrp)) * 100,
            2) AS discount_percentage
FROM
    blinkit_products
        JOIN
    blinkit_order_items ON blinkit_order_items.product_id = blinkit_products.product_id; 
    
-- How many unique customers have placed orders?
SELECT 
    COUNT(DISTINCT (customer_id)) AS unique_customer
FROM
    blinkit_customer
WHERE
    customer_id IN (SELECT customer_id FROM blinkit_orders
        WHERE order_id);
        
-- How many customers have placed more than one order
SELECT 
    COUNT(customer_id)
FROM
    blinkit_customer
WHERE
    customer_id IN (SELECT 
            customer_id
        FROM
            (SELECT 
                customer_id, COUNT(order_id) AS order_count
            FROM
                blinkit_orders
            GROUP BY customer_id) AS order_c
        WHERE
            order_count > 1);
        
-- What is the average order value (AVO) ?
SELECT 
    ROUND(SUM(a.quantity * b.price) / COUNT(a.order_id),2) 
    AS AVO
FROM
    blinkit_order_items a
        JOIN
    blinkit_products b ON a.product_id = b.product_id;

-- Who are the top 10 high-value customers based on total spending ?
SELECT 
    a.customer_name, SUM(b.order_total) AS spend
FROM
    blinkit_customer a
        JOIN
    blinkit_orders b ON a.customer_id = b.customer_id
GROUP BY customer_name
ORDER BY spend DESC
LIMIT 10;

-- What are the most common customer segments
SELECT DISTINCT
    customer_segment AS segment,
    COUNT(customer_id) AS comman_customer
FROM
    blinkit_customer
GROUP BY segment
ORDER BY comman_customer DESC;

-- What is the most common payment method among high-value customers?
SELECT DISTINCT
    payment_method AS payment,
    COUNT(customer_id) AS customer_count
FROM
    blinkit_orders
GROUP BY payment
ORDER BY customer_count DESC;