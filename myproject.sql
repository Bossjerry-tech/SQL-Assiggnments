
-- GERALD PROJECT--

-- STEP 1: Create a working schema
CREATE SCHEMA IF NOT EXISTS gerald1;

-- STEP 2: Create core tables
-- The tables to represent users, products, activity, and sales.

-- Users: basic customer details
CREATE TABLE IF NOT EXISTS gerald1.users (
    user_id INT PRIMARY KEY,      
    full_name VARCHAR(100),       
    email VARCHAR(100),          
    region VARCHAR(50),            
    signup_date DATE               
);

-- Products: items available for purchase
CREATE TABLE IF NOT EXISTS gerald1.products (
    product_id INT PRIMARY KEY,   
    product_nme VARCHAR(100),     
    price DECIMAL(10,2)            
);

-- Sessions: tracks user visits to the website
CREATE TABLE IF NOT EXISTS gerald1.sessions (
    session_id INT PRIMARY KEY,   
    user_id INT,                  
    session_date DATE,            
    page_views INT,              
    device VARCHAR(50)           
);

-- Orders: each purchase made by a user
CREATE TABLE IF NOT EXISTS gerald1.orders (
    order_id INT PRIMARY KEY,     
    user_id INT,                
    order_date DATE              
);

-- Order Items: what exactly was bought in each order
CREATE TABLE IF NOT EXISTS gerald1.order_items (
    order_item_id INT PRIMARY KEY, 
    order_id INT,              
    product_id INT,              
    quantity INT                
);


-- STEP 3: Insert sample data
-- We use ON CONFLICT to avoid duplicate errors

-- Users
INSERT INTO gerald1.users (user_id, full_name, email, region, signup_date) VALUES
(1, 'Alice Mwangi', 'alice@example.com', 'Nairobi', '2023-01-01'),
(2, 'Brian Otieno', 'brian@example.com', 'Mombasa', '2023-02-15'),
(3, 'Catherine Njeri', 'catherine@example.com', 'Nairobi', '2023-03-10')
ON CONFLICT (user_id) DO NOTHING;

-- Products
INSERT INTO gerald1.products (product_id, product_name, price) VALUES
(1, 'Smartphone', 15000),
(2, 'Laptop', 55000),
(3, 'Headphones', 5000)
ON CONFLICT (product_id) DO NOTHING;

-- Sessions (user activity)
INSERT INTO gerald1.sessions (session_id, user_id, session_date, page_views, device) VALUES
(1, 1, '2023-03-01', 5, 'Mobile'),
(2, 1, '2023-03-15', 3, 'Desktop'),
(3, 2, '2023-02-20', 2, 'Mobile')
ON CONFLICT (session_id) DO NOTHING;

-- Orders
INSERT INTO gerald1.orders (order_id, user_id, order_date) VALUES
(1, 1, '2023-03-05'),
(2, 1, '2023-03-20'),
(3, 2, '2023-02-25')
ON CONFLICT (order_id) DO NOTHING;

-- Order items (what was bought)
INSERT INTO gerald1.order_items (order_item_id, order_id, product_id, quantity) VALUES
(1, 1, 1, 1), 
(2, 1, 3, 2),   
(3, 2, 2, 1),   
(4, 3, 3, 1)    
ON CONFLICT (order_item_id) DO NOTHING;


-- STEP 4: Engagement metrics
SELECT
    u.user_id,
    u.full_name,
    u.email,
    u.region,
    COUNT(s.session_id) AS total_sessions,     
    COALESCE(SUM(s.page_views), 0) AS total_page_views,
    MAX(s.session_date) AS last_active_date      
FROM gerald1.users u
LEFT JOIN gerald1.sessions s
    ON u.user_id = s.user_id
GROUP BY u.user_id, u.full_name, u.email, u.region
ORDER BY u.full_name;



-- STEP 5: Financial metrics
SELECT
    u.user_id,
    u.full_name,
    COUNT(o.order_id) AS total_orders,   
    COALESCE(SUM(oi.quantity * p.price), 0) AS total_spend,

    -- Average amount spent per order
    CASE
        WHEN COUNT(o.order_id) > 0
        THEN SUM(oi.quantity * p.price) / COUNT(o.order_id)
        ELSE 0
    END AS avg_order_value

FROM gerald1.users u
LEFT JOIN gerald1.orders o
    ON u.user_id = o.user_id
LEFT JOIN gerald1.order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN gerald1.products p
    ON oi.product_id = p.product_id
GROUP BY u.user_id, u.full_name
ORDER BY total_spend DESC;



-- STEP 6:I combination
-- Combine engagement + financial + business logic
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    u.region

    -- Engagement summary
    COUNT(DISTINCT s.session_id) AS total_sessions,
    COALESCE(SUM(s.page_views), 0) AS total_page_views,
    MAX(s.session_date) AS last_active_date,

    -- Financial summary
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(oi.quantity * p.price), 0) AS total_spend,

    -- Average spend per order
    CASE 
        WHEN COUNT(DISTINCT o.order_id) > 0 
        THEN COALESCE(SUM(oi.quantity * p.price), 0) / COUNT(DISTINCT o.order_id)
        ELSE 0 
    END AS avg_order_value,

    -- Customer segmentation based on spending
    CASE
        WHEN COALESCE(SUM(oi.quantity * p.price), 0) > 30000 THEN 'Platinum'
        WHEN COALESCE(SUM(oi.quantity * p.price), 0) BETWEEN 10000 AND 30000 THEN 'Gold'
        ELSE 'Silver'
    END AS user_segment,

    -- Activity status based on recent usage
    CASE
        WHEN MAX(s.session_date) >= CURRENT_DATE - INTERVAL '30 days'
        THEN 'Active'
        ELSE 'Lapsed'
    END AS activity_status,

    -- Rank users within each region based on spending
    RANK() OVER (
        PARTITION BY u.region
        ORDER BY COALESCE(SUM(oi.quantity * p.price), 0) DESC
    ) AS regional_rank

FROM gerald1.users u
LEFT JOIN gerald1.sessions s ON u.user_id = s.user_id
LEFT JOIN gerald1.orders o ON u.user_id = o.user_id
LEFT JOIN gerald1.order_items oi ON o.order_id = oi.order_id
LEFT JOIN gerald1.products p ON oi.product_id = p.product_id

GROUP BY u.user_id, u.full_name, u.email, u.region

ORDER BY total_spend DESC;
