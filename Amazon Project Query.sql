use amazon;

--                                                         PROJECT QUESTIONS


-- 1.  find all cutsomer who palce order over 500 rupees.
select orders.customer_id,name,sum(total_amount) as "order amount" from customers 
join orders on orders.customer_id = customers.customer_id
where total_amount > 500
group by orders.customer_id;

-- 2. find the total number of orders and total amount spent by each customer.
select orders.customer_id,name,count(*) as "Total Orders",sum(total_amount) as "Total amount spent"from orders 
join customers on orders.customer_id = customers.customer_id
group by customer_id;

-- 3.Calculate total payment per day and a running total across all days.
select * from payments;
select payment_id,payment_date,sum(amount)over(partition by payment_date order by payment_date)  from payments ;
with 
per_day as (select payment_id,payment_date,sum(amount)over(partition by payment_date order by payment_date) as "Per_day_Payment" from payments) ,
all_day as (select payment_id,sum(amount) over (order by payment_date) as "Across_all_day_Payment" from payments)

select per_day.payment_id,payment_date,Per_day_Payment,Across_all_day_Payment  from per_day
join all_day on  per_day.payment_id = all_day.payment_id;


-- 4.Show total quantity sold per product, total revenue, and whether it's low on stock (threshold: < 10).
select products.product_id,name,count(quantity) "Total_qty_sold",sum(order_items.price) as "total revenue" ,stock,
CASE  WHEN stock<10 then 'yes' ELSE 'No' END AS low_on_stock
from products 
left join order_items on products.product_id = order_items.product_id
group by product_id;

-- 5.Calculate customer lifetime value, excluding cancelled or pending orders, and return top 3 customers by value.
select orders.customer_id, name, sum(total_amount)from orders 
join customers on customers.customer_id = orders.customer_id
where status not in ("cancelled", "pending")
group by 1
order by 3 desc limit 3;


-- 6.List all products that have never been sold but are in stock.
select products.product_id,name,count(quantity) "Total_qty_sold" ,stock
from products 
left join order_items on products.product_id = order_items.product_id
group by product_id
having count(quantity) = 0;


-- 7.Show monthly revenue and growth from previous month.
with 
growth as 
(select monthname(payment_date)as month, sum(amount) as monthly_revenue  from payments where payment_date is not null group by month)

select *,sum(amount) over(order by monthly_revenue ) as growth  from growth;
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(total_amount) AS revenue
FROM orders
WHERE status NOT IN ('cancelled', 'pending')
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- 8.Get the highest-selling product (by revenue) for each category.
with 
o as ( select product_id,sum(order_items.price) as "revenue" from order_items group by product_id),
p as (select category_id,name,product_id  from products),
c as ( select category_id,name from categories),
final_data as(select o.product_id, revenue,p.name,c.category_id,rank() over(PARTITION BY p.category_id ORDER BY o.revenue DESC) AS "rank_num" 
from o join p on o.product_id=p.product_id 
join c on c.category_id = p.category_id)

select * from final_data where rank_num=1;

-- 9.Group customers based on their average order value: "High Value" if avg order > 1000,  "Medium Value" if 500–1000, “Low Value" if < 500
with
data as (select c.customer_id,c.name,avg(total_amount) as avg_order from customers c
join orders o on c.customer_id = o.customer_id
group by 1)

select * ,case  when avg_order > 1000 then "High Value"
when avg_order <= 1000 and  avg_order >=500 then "Medium Value"
Else "Low Value"
end as "Avg order value"
from data;


-- 10.List all orders where the total amount is greater than the sum of payments made (i.e., unpaid or underpaid).
select orders.order_id,customer_id,total_amount,COALESCE(SUM(amount), 0) AS total_paid from orders 
left join payments on payments.order_id = orders.order_id
group by 1,customer_id
having total_amount > COALESCE(SUM(amount), 0);

use amazon;
-- 11.For each customer, return the product from which the company earned the most revenue from that customer.
with
c as (select * from customers),
o as ( select * from orders where status!= "pending"),
oi as (select product_id,order_id , price as total_order_amount from order_items ),
p as (select product_id,name from products),
final_data as 
(select c.customer_id, c.name as customer_name ,oi.order_id,total_order_amount,oi.product_id, p.name as product_name,
rank() over(partition by customer_id order by total_order_amount desc) as highest_paid_order
from c 
join o on c.customer_id = o.customer_id  
join oi on oi.order_id = o.order_id 
join p on p.product_id = oi.product_id )

select customer_id, customer_name, order_id, total_order_amount, product_id, product_name from final_data where highest_paid_order = 1;


-- 12.Track how many orders fall into each status and compute drop-off percentage between stages (Pending → Shipped → Delivered).
with 
o as (Select count(order_id) as "total_orders" from orders),
oi as (Select status,count(order_id) as "total_order" from orders group by status)

select status,total_order,round(total_order*100/total_orders,2) as "Dropoff%"from o join oi;

-- 13.Identify customers who spent over $1000 total, but left average review rating < 3.
with
o as (select * from orders where total_amount > 1000),
r as (Select customer_id , avg(rating) as avg_rating from reviews group by customer_id)

select order_id,o.customer_id,total_amount,avg_rating from o join r
where avg_rating < 3 ;


-- 14.For each product, show the difference between its average rating and the average rating of its category.
with 
r as(select product_id, avg(rating) as "products_rating"from reviews group by product_id),
c as (select products.product_id,r.products_rating,category_id,avg(r.products_rating) over(partition by category_id) as "category_rating" from products 
join r on r.product_id = products.product_id)
SELECT product_id,products_rating,category_rating, products_rating - category_rating AS rating_diff
FROM c;

-- 15. For each product, calculate: Starting stock, Quantity sold, Current stock, % sold
with
s_stock as ( select product_id,name,stock as "starting_stock"from products),
q_Sold as (select product_id,count(quantity) as "qty_sold" from order_items group by product_id)

select s_stock.product_id,name,starting_stock,qty_sold,starting_stock - qty_sold as "current_stock",qty_Sold *100/ starting_stock as "%sold"
from s_Stock
join q_Sold on s_Stock.product_id = q_Sold.product_id;

-- 16.For each product, compute: Number of distinct customers who bought, Number who reviewed, Review-to-purchase rate %
with
oi as (Select distinct count(order_id) as "no_of_buyers",product_id from order_items group by product_id),
p as (select product_id,name from products),
r as (Select product_id,count(customer_id) "no_of_reviews"from reviews group by product_id)

select p.product_id,name ,no_of_buyers,no_of_reviews,round( no_of_reviews*100/no_of_buyers,2) as "Review-to-purchase rate %"
from oi 
join p on p.product_id = oi.product_id
join r on p.product_id = r.product_id;


c as (Select customers.customer_id,name from customers join orders on orders.customer_id=customers.customer_id
