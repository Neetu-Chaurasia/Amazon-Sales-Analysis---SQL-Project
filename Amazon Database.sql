create database amazon;
use amazon;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    created_at DATE
);
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100),
    parent_category_id INT NULL,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    price DECIMAL(10,2),
    stock INT,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(50),
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,
    method VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
INSERT INTO customers (customer_id, name, email, phone, created_at) VALUES
(1, 'Alice Johnson', 'alice@example.com', '1234567890', '2023-01-15'),
(2, 'Bob Smith', 'bob@example.com', '0987654321', '2023-02-20'),
(3, 'Carol Taylor', 'carol@example.com', '4567891230', '2023-03-10');
INSERT INTO categories (category_id, name, parent_category_id) VALUES
(1, 'Electronics', NULL),
(2, 'Mobile Phones', 1),
(3, 'Laptops', 1),
(4, 'Home Appliances', NULL),
(5, 'Kitchen Appliances', 4),
(6, 'Smartphones', 2);
INSERT INTO products (product_id, name, description, price, stock, category_id) VALUES
(1, 'iPhone 14', 'Apple smartphone', 999.99, 25, 6),
(2, 'Samsung Galaxy S22', 'Android smartphone', 899.99, 15, 6),
(3, 'Dell XPS 13', 'Laptop with Windows 11', 1199.99, 8, 3),
(4, 'LG Refrigerator', 'Double-door fridge', 799.99, 12, 4),
(5, 'Philips Mixer', 'Kitchen appliance for blending', 49.99, 30, 5);
INSERT INTO orders (order_id, customer_id, order_date, status, total_amount) VALUES
(1, 1, '2023-04-01', 'Delivered', 1899.98),
(2, 2, '2023-04-03', 'Shipped', 849.99),
(3, 1, '2023-05-01', 'Pending', 999.99),
(4, 3, '2023-06-10', 'Delivered', 49.99);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price) VALUES
(1, 1, 1, 1, 999.99),
(2, 1, 2, 1, 899.99),
(3, 2, 2, 1, 849.99),
(4, 3, 1, 1, 999.99),
(5, 4, 5, 1, 49.99);
INSERT INTO payments (payment_id, order_id, amount, payment_date, method) VALUES
(1, 1, 1899.98, '2023-04-01', 'Credit Card'),
(2, 2, 849.99, '2023-04-04', 'PayPal'),
(3, 4, 49.99, '2023-06-11', 'Credit Card');
INSERT INTO reviews (review_id, customer_id, product_id, rating, review_text, review_date) VALUES
(1, 1, 1, 5, 'Excellent phone!', '2023-04-05'),
(2, 2, 2, 4, 'Good, but expensive.', '2023-04-06'),
(3, 3, 5, 3, 'Does the job.', '2023-06-12');

use amazon;

INSERT INTO customers (customer_id, name, email, phone, created_at) VALUES
(4, 'David Green', 'david@example.com', '1112223333', '2023-07-01'),
(5, 'Eva Martin', 'eva@example.com', '2223334444', '2023-08-05'),
(6, 'Frank White', 'frank@example.com', '3334445555', '2023-09-09');
INSERT INTO orders (order_id, customer_id, order_date, status, total_amount) VALUES
(9, 4, '2023-08-15', 'Delivered', 1749.98),
(10, 5, '2023-08-20', 'Pending', 1099.99),
(11, 6, '2023-09-01', 'Delivered', 899.99),
(12, 4, '2023-09-25', 'Shipped', 49.99);
INSERT INTO products (product_id, name, description, price, stock, category_id) VALUES
(6, 'Asus ZenBook', 'High-end ultrabook', 1099.99, 10, 3);

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price) VALUES
(10, 9, 3, 1, 1199.99),
(11, 9, 2, 1, 549.99),
(12, 10, 6, 1, 1099.99),
(13, 11, 2, 1, 899.99),
(14, 12, 5, 1, 49.99);
INSERT INTO payments (payment_id, order_id, amount, payment_date, method) VALUES
(8, 9, 1749.98, '2023-08-15', 'Credit Card'),
(9, 10, 0.00, NULL, 'N/A'),  -- Pending order, no payment yet
(10, 11, 899.99, '2023-09-02', 'PayPal'),
(11, 12, 49.99, '2023-09-26', 'UPI');
INSERT INTO reviews (review_id, customer_id, product_id, rating, review_text, review_date) VALUES
(7, 4, 3, 4, 'Solid performance.', '2023-08-16'),
(8, 5, 6, 2, 'Too slow for the price.', '2023-08-25'),
(9, 6, 2, 3, 'Okay but battery drains fast.', '2023-09-03');
