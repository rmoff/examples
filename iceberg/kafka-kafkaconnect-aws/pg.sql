CREATE SCHEMA us_east;
CREATE SCHEMA us_west;
CREATE SCHEMA europe;
CREATE SCHEMA asia;

-- Create the same orders table in each schema
CREATE TABLE us_east.orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    product VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    order_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE us_west.orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    product VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    order_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE europe.orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    product VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    order_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE asia.orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    product VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    order_date DATE DEFAULT CURRENT_DATE
);

-- Sample data for US East
INSERT INTO us_east.orders (customer_name, product, quantity, price) VALUES
('Peter Parker', 'Spider-Man Web Shooters', 2, 149.99),
('Bruce Wayne', 'Batmobile Model Kit', 1, 299.99),
('Tony Stark', 'Arc Reactor Replica', 1, 199.99),
('Clark Kent', 'Superman Cape (Adult)', 1, 49.99),
('Diana Prince', 'Wonder Woman Lasso', 1, 89.99);

-- Sample data for US West
INSERT INTO us_west.orders (customer_name, product, quantity, price) VALUES
('Scott Lang', 'Ant-Man Helmet', 1, 179.99),
('Natasha Romanoff', 'Black Widow Gauntlets', 2, 129.99),
('Steve Rogers', 'Captain America Shield', 1, 249.99),
('Wanda Maximoff', 'Scarlet Witch Costume', 1, 199.99),
('Carol Danvers', 'Captain Marvel Flight Suit', 1, 399.99);

-- Sample data for Europe
INSERT INTO europe.orders (customer_name, product, quantity, price) VALUES
('Arthur Curry', 'Aquaman Trident', 1, 189.99),
('Barry Allen', 'Flash Costume Ring', 1, 79.99),
('Hal Jordan', 'Green Lantern Power Ring', 1, 299.99),
('Victor Stone', 'Cyborg Arm Attachment', 1, 449.99),
('Kara Zor-El', 'Supergirl Cape', 1, 59.99);

-- Sample data for Asia
INSERT INTO asia.orders (customer_name, product, quantity, price) VALUES
('Shang-Chi', 'Ten Rings Replica Set', 1, 349.99),
('Kamala Khan', 'Ms. Marvel Stretchy Gloves', 2, 39.99),
('Danny Rand', 'Iron Fist Meditation Mat', 1, 89.99),
('Luke Cage', 'Power Man Chain Belt', 1, 69.99),
('Jessica Jones', 'Alias Investigations Badge', 1, 29.99);


-- Customers table
CREATE TABLE europe.customers (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100),
    registration_date DATE DEFAULT CURRENT_DATE
);

-- Products table
CREATE TABLE europe.products (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0
);

-- Shipments table
CREATE TABLE europe.shipments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER,
    tracking_number VARCHAR(100),
    carrier VARCHAR(100),
    ship_date DATE,
    delivery_date DATE,
    status VARCHAR(50) DEFAULT 'pending'
);

-- Populate customers table
INSERT INTO europe.customers (customer_name, email, city, country, registration_date) VALUES
('Arthur Curry', 'a.curry@email.com', 'London', 'UK', '2023-01-15'),
('Barry Allen', 'b.allen@email.com', 'Paris', 'France', '2023-02-20'),
('Hal Jordan', 'h.jordan@email.com', 'Berlin', 'Germany', '2023-03-10'),
('Victor Stone', 'v.stone@email.com', 'Rome', 'Italy', '2023-04-05'),
('Kara Zor-El', 'k.zorel@email.com', 'Madrid', 'Spain', '2023-05-12');

-- Populate products table
INSERT INTO europe.products (product_name, category, price, stock_quantity) VALUES
('Aquaman Trident', 'Collectibles', 189.99, 25),
('Flash Costume Ring', 'Accessories', 79.99, 50),
('Green Lantern Power Ring', 'Collectibles', 299.99, 15),
('Cyborg Arm Attachment', 'Costumes', 449.99, 8),
('Supergirl Cape', 'Costumes', 59.99, 30),
('Justice League Poster', 'Merchandise', 19.99, 100);

-- Populate shipments table
INSERT INTO europe.shipments (order_id, tracking_number, carrier, ship_date, delivery_date, status) VALUES
(1, 'EU001234567', 'DHL', '2024-06-01', '2024-06-03', 'delivered'),
(2, 'EU001234568', 'FedEx', '2024-06-02', '2024-06-04', 'delivered'),
(3, 'EU001234569', 'UPS', '2024-06-03', NULL, 'in_transit'),
(4, 'EU001234570', 'DHL', '2024-06-04', NULL, 'shipped'),
(5, 'EU001234571', 'FedEx', '2024-06-05', NULL, 'pending');
