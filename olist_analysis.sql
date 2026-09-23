CREATE DATABASE olistdb;
USE olistdb;

DROP TABLE IF EXISTS o_list_customers_dataset CASCADE;
CREATE TABLE olist_customers_dataset (
customer_id VARCHAR(50) PRIMARY key,
customer_unique_id VARCHAR(50),
customer_zip_code_prefix VARCHAR(50),
customer_city VARCHAR(50),
customer_state VARCHAR(50)
);



DROP TABLE IF EXISTS geo_location_dataset CASCADE;
CREATE TABLE geo_location_dataset (
geolocation_zip_code_prefix VARCHAR(100),
geolocation_lat NUMERIC,
geolocation_lng NUMERIC,
geolocation_city VARCHAR(50),
geolocation_state VARCHAR(50)
);

DROP TABLE IF EXISTS olist_order_items_dataset CASCADE;
CREATE TABLE olist_order_items_dataset (
order_id VARCHAR(100) PRIMARY key,
order_item_id INT, 
product_id VARCHAR(100),
seller_id VARCHAR(100),
shipping_limit_date TIMESTAMP,
price DECIMAL(10,2),
freight_value DECIMAL(10,2)
);


DROP TABLE IF EXISTS olist_order_payments_dataset CASCADE;
CREATE TABLE olist_order_payments_dataset (
order_id VARCHAR(100) PRIMARY key,
payment_sequential INT,
payment_type VARCHAR(50),
payment_installments INT,
payment_value NUMERIC 
);


DROP TABLE IF EXISTS olist_order_reviews_dataset CASCADE;
CREATE TABLE olist_order_reviews_dataset (
review_id VARCHAR(100),
order_id VARCHAR(100),
review_score INT,
review_comment_title VARCHAR(50),
review_comment_message TEXT,
review_creation_date TIMESTAMP,
review_answer_timestamp TIMESTAMP
);

DROP TABLE IF EXISTS olist_orders_dataset CASCADE;
CREATE TABLE olist_orders_dataset (
order_id VARCHAR(100) PRIMARY key,
customer_id VARCHAR(100),
order_status VARCHAR(50),
order_purchase_timestamp TIMESTAMP,
order_approved_at TIMESTAMP,
order_delivered_carrier_date TIMESTAMP,
order_delivered_customer_date TIMESTAMP,
order_estimated_delivery_date TIMESTAMP
);


DROP TABLE IF EXISTS olist_products_dataset CASCADE;
CREATE TABLE olist_products_dataset (
product_id VARCHAR(100) PRIMARY key,
product_category_name VARCHAR(50),
product_name_lenght INT,
product_description_lenght INT,
product_photos_qty INT,
product_weight_g INT, 
product_length_cm INT, 
product_height_cm INT,
product_width_cm INT
);


DROP TABLE IF EXISTS olist_sellers_dataset CASCADE;
CREATE TABLE olist_sellers_dataset (
seller_id VARCHAR(100) PRIMARY key,
seller_zip_code_prefix VARCHAR(50),
seller_city VARCHAR(50),
seller_state VARCHAR(50)
);


DROP TABLE IF EXISTS product_category_name_translation CASCADE;
CREATE TABLE product_category_name_translation (
product_category_name VARCHAR(50) PRIMARY key,
product_category_name_english VARCHAR(50)
);



SHOW TABLES;

-- foreign_keys

ALTER TABLE olist_orders_dataset
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id) REFERENCES olist_customers_dataset(customer_id);

-- Link Order Items to Orders, Products, and Sellers

ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT fk_items_order
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id),
ADD CONSTRAINT fk_items_products
FOREIGN KEY (product_id) REFERENCES olist_products_dataset(product_id),
ADD CONSTRAINT fk_items_sellers
FOREIGN KEY (seller_id) REFERENCES olist_sellers_dataset(seller_id);


-- Link Order Payments to Orders

ALTER TABLE olist_order_payments_dataset
ADD CONSTRAINT fk_payments_orders
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id);

-- Link Order Reviews to Orders

ALTER TABLE olist_order_reviews_dataset
ADD CONSTRAINT fk_reviews_orders
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id);


-- Copy com

-- customers

LOAD DATA LOCAL INFILE 'D:/datasets sql/olistdb.sql/olist_customers_dataset.csv'
INTO TABLE olist_customers_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- products 

LOAD DATA LOCAL INFILE 'D:/datasets sql/olistdb.sql/olist_products_dataset.csv'
INTO TABLE olist_products_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- orders

LOAD DATA LOCAL INFILE 'D:/datasets sql/olistdb.sql/olist_orders_dataset.csv'
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- sellers

LOAD DATA LOCAL INFILE 'D:/datasets sql/olistdb.sql/olist_sellers_dataset.csv'
INTO TABLE olist_sellers_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- order items

LOAD DATA LOCAL INFILE 'D:/datasets sql/olistdb.sql/olist_order_items_dataset.csv'
INTO TABLE olist_order_items_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

ALTER TABLE olist_order_items_dataset
MODIFY price DECIMAL(10,2),
MODIFY freight_value DECIMAL(10,2);

SELECT COUNT(*) as total_order_items
FROM olist_order_items_dataset;


-- order reviews

LOAD DATA LOCAL INFILE 'D:/datasets sql/olistdb.sql/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- order_payments

LOAD DATA LOCAL INFILE 'D:/datasets sql/olistdb.sql/olist_order_payments_dataset.csv'
INTO TABLE olist_order_payments_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- product_category_name_translation

LOAD DATA LOCAL INFILE 'D:/datasets sql/olistdb.sql/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- geolocation

LOAD DATA LOCAL INFILE 'D:/datasets sql/olistdb.sql/olist_geolocation_dataset.csv'
INTO TABLE geo_location_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Indexes

-- Orders

CREATE INDEX  ix_orders_order_id ON olist_orders_dataset(order_id);
CREATE INDEX ix_orders_customer_id ON olist_orders_dataset(customer_id);
CREATE INDEX ix_orders_purchase_date ON olist_orders_dataset(order_purchase_timestamp);

-- Order Items

CREATE INDEX  ix_items_order_id ON olist_order_items_dataset(order_id);
CREATE INDEX  ix_items_product_id ON olist_order_items_dataset(product_id);
CREATE INDEX ix_items_seller_id ON olist_order_items_dataset(seller_id);

-- Customers

CREATE INDEX ix_customers_customer_id ON olist_customers_dataset(customer_id);
CREATE INDEX ix_customers_state ON olist_customers_dataset(customer_state);

-- Payments

CREATE INDEX ix_payments_order_id ON olist_order_payments_dataset(order_id);

-- Reviews

CREATE INDEX ix_reviews_order_id ON olist_order_reviews_dataset(order_id);


-- views

CREATE OR REPLACE VIEW bi_dim_product AS
SELECT
    p.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    (p.product_length_cm * p.product_height_cm * p.product_width_cm) AS volume_cm3
FROM olistdb.olist_products_dataset p
LEFT JOIN olistdb.product_category_name_translation t
ON t.product_category_name = p.product_category_name;


USE olistdb;

CREATE OR REPLACE VIEW bi_fact_review_latest AS
SELECT
    order_id,
    review_score,
    review_creation_date,
    review_answer_timestamp
FROM (
    SELECT
        r.order_id,
        r.review_score,
        r.review_creation_date,
        r.review_answer_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY r.order_id
            ORDER BY r.review_creation_date DESC
        ) AS rn
    FROM olist_order_reviews_dataset r
) x
WHERE rn = 1;



USE olistdb;

CREATE OR REPLACE VIEW bi_fact_order AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,

    -- Purchase date
    DATE(o.order_purchase_timestamp) AS purchase_date,

    -- Purchase month
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS purchase_month,

    -- Delivered date
    DATE(o.order_delivered_customer_date) AS delivered_date,

    -- Estimated delivery date
    DATE(o.order_estimated_delivery_date) AS estimated_date,

    -- Delivery days
    CASE
        WHEN o.order_status = 'delivered'
             AND o.order_delivered_customer_date IS NOT NULL
        THEN DATEDIFF(
            o.order_delivered_customer_date,
            o.order_purchase_timestamp
        )
        ELSE NULL
    END AS delivery_days,

    -- Late delivery flag
    CASE
        WHEN o.order_status = 'delivered'
             AND o.order_delivered_customer_date IS NOT NULL
             AND o.order_estimated_delivery_date IS NOT NULL
             AND o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 1
        ELSE 0
    END AS is_late,

    c.customer_unique_id,
    c.customer_city,
    c.customer_state

FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON c.customer_id = o.customer_id;


USE olistdb;

CREATE OR REPLACE VIEW bi_fact_sales AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,

    DATE(oi.shipping_limit_date) AS shipping_limit_date,

    oi.price,
    oi.freight_value,

    fo.customer_id,
    fo.customer_unique_id,
    fo.order_status,
    fo.purchase_date,
    fo.purchase_month,
    fo.delivered_date,
    fo.estimated_date,
    fo.delivery_days,
    fo.is_late,
    fo.customer_city,
    fo.customer_state,

    dp.category,

    r.review_score,

    p.payment_type,
    p.payment_installments,
    p.payment_value,

    s.seller_city,
    s.seller_state

FROM olist_order_items_dataset oi

JOIN bi_fact_order fo
    ON fo.order_id = oi.order_id

LEFT JOIN bi_dim_product dp
    ON dp.product_id = oi.product_id

LEFT JOIN bi_fact_review_latest r
    ON r.order_id = oi.order_id

LEFT JOIN olist_order_payments_dataset p
    ON p.order_id = oi.order_id

LEFT JOIN olist_sellers_dataset s
    ON s.seller_id = oi.seller_id;


USE olistdb;

CREATE OR REPLACE VIEW bi_payments_order AS
SELECT
    op.order_id,

    SUM(op.payment_value) AS order_payment_value,

    MAX(op.payment_installments) AS order_payment_installments,

    SUBSTRING_INDEX(
        GROUP_CONCAT(
            op.payment_type
            ORDER BY op.payment_value DESC
        ),
        ',',
        1
    ) AS order_payment_type

FROM olist_order_payments_dataset op
GROUP BY op.order_id;










