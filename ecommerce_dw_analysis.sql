/* ============================================================
   E-Commerce Analytics for Sales & Returns Optimization
   Data Warehouse Implementation & Analysis
   Platform: Snowflake
   ============================================================ */

/* ============================================================
   1. ENVIRONMENT SETUP
   ============================================================ */

CREATE WAREHOUSE IF NOT EXISTS sales_wh 
WITH WAREHOUSE_SIZE = 'XSMALL';

CREATE DATABASE IF NOT EXISTS amazon_analytics_db;

CREATE SCHEMA IF NOT EXISTS amazon_analytics_db.raw_data;
CREATE SCHEMA IF NOT EXISTS amazon_analytics_db.analytics;


/* ============================================================
   2. RAW TABLE CREATION
   ============================================================ */

CREATE OR REPLACE TABLE raw_data.raw_sales_data (
    index_col INT,
    order_id STRING,
    order_date STRING,
    status STRING,
    fulfilment STRING,
    sales_channel STRING,
    ship_service_level STRING,
    style STRING,
    sku STRING,
    category STRING,
    size STRING,
    asin STRING,
    courier_status STRING,
    qty INT,
    currency STRING,
    amount FLOAT,
    ship_city STRING,
    ship_state STRING,
    ship_postal_code FLOAT,
    ship_country STRING,
    promotion_ids STRING,
    b2b BOOLEAN,
    fulfilled_by STRING,
    unnamed_22 STRING
);


/* ============================================================
   3. EDA (EXPLORATORY DATA ANALYSIS)
   ============================================================ */

/* Total Records */
SELECT COUNT(*) AS total_rows 
FROM raw_data.raw_sales_data;

/* Null Check */
SELECT 
    COUNT(*) AS total_rows,
    COUNT(order_id) AS non_null_orders,
    COUNT(amount) AS non_null_amounts
FROM raw_data.raw_sales_data;

/* Date Range */
SELECT 
    MIN(order_date) AS start_date, 
    MAX(order_date) AS end_date
FROM raw_data.raw_sales_data;

/* Category Distribution */
SELECT 
    category, 
    COUNT(*) AS total_records
FROM raw_data.raw_sales_data
GROUP BY category
ORDER BY total_records DESC;

/* Revenue Distribution */
SELECT 
    MIN(amount) AS min_value,
    MAX(amount) AS max_value,
    AVG(amount) AS avg_value
FROM raw_data.raw_sales_data;

/* Order Status Distribution */
SELECT 
    status, 
    COUNT(*) AS total_count
FROM raw_data.raw_sales_data
GROUP BY status;

/* Geographic Distribution */
SELECT 
    ship_state, 
    COUNT(*) AS total_orders
FROM raw_data.raw_sales_data
GROUP BY ship_state
ORDER BY total_orders DESC;

/* Channel Distribution */
SELECT 
    sales_channel, 
    fulfilment, 
    COUNT(*) AS total_orders
FROM raw_data.raw_sales_data
GROUP BY sales_channel, fulfilment;


/* ============================================================
   4. DIMENSION TABLES
   ============================================================ */

/* Product Dimension */
CREATE OR REPLACE TABLE analytics.dim_product AS
SELECT DISTINCT
    asin AS product_id,
    category,
    style,
    size
FROM raw_data.raw_sales_data;

/* Time Dimension */
CREATE OR REPLACE TABLE analytics.dim_time AS
SELECT DISTINCT
    TRY_TO_DATE(order_date, 'MM-DD-YY') AS date_id,
    MONTH(TRY_TO_DATE(order_date, 'MM-DD-YY')) AS month,
    YEAR(TRY_TO_DATE(order_date, 'MM-DD-YY')) AS year,
    QUARTER(TRY_TO_DATE(order_date, 'MM-DD-YY')) AS quarter
FROM raw_data.raw_sales_data;

/* Geography Dimension */
CREATE OR REPLACE TABLE analytics.dim_geography AS
SELECT DISTINCT
    MD5(CONCAT(ship_city, ship_state, ship_country)) AS geo_id,
    ship_city,
    ship_state,
    ship_country
FROM raw_data.raw_sales_data;

/* Sales Channel Dimension */
CREATE OR REPLACE TABLE analytics.dim_sales_channel AS
SELECT DISTINCT
    MD5(CONCAT(sales_channel, fulfilment, ship_service_level)) AS channel_id,
    sales_channel,
    fulfilment,
    ship_service_level
FROM raw_data.raw_sales_data;

/* Promotion Dimension */
CREATE OR REPLACE TABLE analytics.dim_promotion AS
SELECT DISTINCT
    MD5(IFNULL(promotion_ids, 'NO_PROMO')) AS promo_id,
    promotion_ids AS promo_description
FROM raw_data.raw_sales_data;

/* B2B Dimension */
CREATE OR REPLACE TABLE analytics.dim_b2b_status AS
SELECT DISTINCT
    b2b AS is_b2b,
    CASE WHEN b2b THEN 'B2B' ELSE 'B2C' END AS segment_name
FROM raw_data.raw_sales_data;


/* ============================================================
   5. FACT TABLES
   ============================================================ */

/* Sales Fact */
CREATE OR REPLACE TABLE analytics.fact_sales AS
SELECT 
    order_id,
    TRY_TO_DATE(order_date, 'MM-DD-YY') AS date_id,
    asin AS product_id,
    MD5(CONCAT(ship_city, ship_state, ship_country)) AS geo_id,
    MD5(CONCAT(sales_channel, fulfilment, ship_service_level)) AS channel_id,
    MD5(IFNULL(promotion_ids, 'NO_PROMO')) AS promo_id,
    b2b,
    qty,
    amount
FROM raw_data.raw_sales_data
WHERE status = 'Shipped - Delivered to Buyer';

/* Returns Fact */
CREATE OR REPLACE TABLE analytics.fact_returns AS
SELECT 
    order_id,
    TRY_TO_DATE(order_date, 'MM-DD-YY') AS date_id,
    asin AS product_id,
    MD5(CONCAT(ship_city, ship_state, ship_country)) AS geo_id,
    MD5(CONCAT(sales_channel, fulfilment, ship_service_level)) AS channel_id,
    b2b,
    qty,
    status AS return_reason
FROM raw_data.raw_sales_data
WHERE status = 'Cancelled';


/* ============================================================
   6. ANALYTICAL QUERIES
   ============================================================ */

/* Overall Performance */
SELECT
    SUM(amount) AS total_revenue,
    COUNT(*) AS total_orders,
    AVG(amount) AS avg_order_value
FROM analytics.fact_sales;

/* Revenue by Category */
SELECT 
    p.category,
    SUM(f.amount) AS revenue
FROM analytics.fact_sales f
JOIN analytics.dim_product p 
    ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

/* Monthly Sales Trend */
SELECT 
    t.year,
    t.month,
    SUM(f.amount) AS revenue
FROM analytics.fact_sales f
JOIN analytics.dim_time t 
    ON f.date_id = t.date_id
GROUP BY t.year, t.month
ORDER BY t.year, t.month;

/* Geographic Revenue */
SELECT 
    g.ship_state,
    SUM(f.amount) AS revenue
FROM analytics.fact_sales f
JOIN analytics.dim_geography g 
    ON f.geo_id = g.geo_id
GROUP BY g.ship_state
ORDER BY revenue DESC;

/* Returns Analysis */
SELECT 
    g.ship_state,
    COUNT(r.order_id) AS return_count
FROM analytics.fact_returns r
JOIN analytics.dim_geography g 
    ON r.geo_id = g.geo_id
GROUP BY g.ship_state
ORDER BY return_count DESC;

/* Monthly Sales by Channel */
SELECT 
    t.month,
    c.sales_channel,
    SUM(f.amount) AS revenue
FROM analytics.fact_sales f
JOIN analytics.dim_time t 
    ON f.date_id = t.date_id
JOIN analytics.dim_sales_channel c 
    ON f.channel_id = c.channel_id
GROUP BY t.month, c.sales_channel
ORDER BY t.month;

/* Category Contribution */
SELECT 
    p.category,
    SUM(f.amount) AS revenue,
    SUM(f.amount) * 100.0 / SUM(SUM(f.amount)) OVER() AS revenue_percentage
FROM analytics.fact_sales f
JOIN analytics.dim_product p 
    ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;


