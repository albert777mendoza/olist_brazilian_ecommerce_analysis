-- =====================================================
-- Olist Brazilian E-commerce Analysis
-- File: 00_esquema_y_carga.sql
-- Purpose: Create tables and document CSV imports
-- Database: olist
-- =====================================================

-- 1. CUSTOMERS
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(100),
    customer_state VARCHAR(2)
);

-- 2. ORDERS
CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- 3. ORDER ITEMS
CREATE TABLE IF NOT EXISTS order_items (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2)
);

-- 4. PRODUCTS
CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

-- 5. SELLERS
CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR(100),
    seller_state VARCHAR(2)
);

-- 6. ORDER PAYMENTS
CREATE TABLE IF NOT EXISTS order_payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(30),
    payment_installments INTEGER,
    payment_value NUMERIC(10, 2)
);

-- 7. ORDER REVIEWS
CREATE TABLE IF NOT EXISTS order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-- 8. GEOLOCATION
CREATE TABLE IF NOT EXISTS geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat NUMERIC(10, 7),
    geolocation_lng NUMERIC(10, 7),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(2)
);

-- 9. PRODUCT CATEGORY TRANSLATION
CREATE TABLE IF NOT EXISTS product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

-- =====================================================
-- DATA LOADING
-- =====================================================
-- The 9 CSV files were imported into the tables above
-- using PostgreSQL psql \copy commands.
--
-- Source folder:
-- data/
--
-- Imported datasets:
-- 1. olist_customers_dataset.csv
-- 2. olist_orders_dataset.csv
-- 3. olist_order_items_dataset.csv
-- 4. olist_products_dataset.csv
-- 5. olist_sellers_dataset.csv
-- 6. olist_order_payments_dataset.csv
-- 7. olist_order_reviews_dataset.csv
-- 8. olist_geolocation_dataset.csv
-- 9. product_category_name_translation.csv
--
-- All 9 tables were verified with COUNT(*).
-- =====================================================

-- =====================================================
-- CSV IMPORT COMMANDS
-- Run these commands in PostgreSQL SQL Shell (psql)
-- Database: olist
-- =====================================================

-- 1. Customers
\copy customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state) FROM 'C:/Users/mateg/Documents/triple_ten/brasilian_ecommerce/data/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 2. Orders
\copy orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date) FROM 'C:/Users/mateg/Documents/triple_ten/brasilian_ecommerce/data/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 3. Order items
\copy order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value) FROM 'C:/Users/mateg/Documents/triple_ten/brasilian_ecommerce/data/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 4. Products
\copy products (product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm) FROM 'C:/Users/mateg/Documents/triple_ten/brasilian_ecommerce/data/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 5. Sellers
\copy sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state) FROM 'C:/Users/mateg/Documents/triple_ten/brasilian_ecommerce/data/olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 6. Order payments
\copy order_payments (order_id, payment_sequential, payment_type, payment_installments, payment_value) FROM 'C:/Users/mateg/Documents/triple_ten/brasilian_ecommerce/data/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 7. Order reviews
\copy order_reviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp) FROM 'C:/Users/mateg/Documents/triple_ten/brasilian_ecommerce/data/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 8. Geolocation
\copy geolocation (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state) FROM 'C:/Users/mateg/Documents/triple_ten/brasilian_ecommerce/data/olist_geolocation_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 9. Product category translation
\copy product_category_name_translation (product_category_name, product_category_name_english) FROM 'C:/Users/mateg/Documents/triple_ten/brasilian_ecommerce/data/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
