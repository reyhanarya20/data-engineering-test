-- Cek DB maju_jaya_dw#####################################################
SHOW DATABASES;

-- Pilih DB maju_jaya_dw#####################################################
USE maju_jaya_dw;

-- Bikin table raw#####################################################
USE maju_jaya_dw;

DROP TABLE IF EXISTS customer_addresses_raw;
DROP TABLE IF EXISTS after_sales_raw;
DROP TABLE IF EXISTS sales_raw;
DROP TABLE IF EXISTS customers_raw;

CREATE TABLE customers_raw (
    id INT,
    name VARCHAR(255),
    dob VARCHAR(50),
    created_at DATETIME(3)
);

CREATE TABLE sales_raw (
    vin VARCHAR(50),
    customer_id INT,
    model VARCHAR(100),
    invoice_date DATE,
    price VARCHAR(50),
    created_at DATETIME(3)
);

CREATE TABLE after_sales_raw (
    service_ticket VARCHAR(50),
    vin VARCHAR(50),
    customer_id INT,
    model VARCHAR(100),
    service_date DATE,
    service_type VARCHAR(20),
    created_at DATETIME(3)
);

CREATE TABLE customer_addresses_raw (
    id INT,
    customer_id INT,
    address VARCHAR(255),
    city VARCHAR(100),
    province VARCHAR(100),
    created_at DATETIME(3)
);

-- masukin sample data dari soal###################################################
USE maju_jaya_dw;

INSERT INTO customers_raw (id, name, dob, created_at) VALUES
(1, 'Antonio', '1998-08-04', '2025-03-01 14:24:40.012'),
(2, 'Brandon', '2001-04-21', '2025-03-02 08:12:54.003'),
(3, 'Charlie', '1980/11/15', '2025-03-02 11:20:02.391'),
(4, 'Dominikus', '14/01/1995', '2025-03-03 09:50:41.852'),
(5, 'Erik', '1900-01-01', '2025-03-03 17:22:03.198'),
(6, 'PT Black Bird', NULL, '2025-03-04 12:52:16.122');

INSERT INTO sales_raw (vin, customer_id, model, invoice_date, price, created_at) VALUES
('JIS8135SAD', 1, 'RAIZA', '2025-03-01', '350.000.000', '2025-03-01 14:24:40.012'),
('MAS8160POE', 3, 'RANGGO', '2025-05-19', '430.000.000', '2025-05-19 14:29:21.003'),
('JLK1368KDE', 4, 'INNAVO', '2025-05-22', '600.000.000', '2025-05-22 16:10:28.120'),
('JLK1869KDF', 6, 'VELOS', '2025-08-02', '390.000.000', '2025-08-02 14:04:31.021'),
('JLK1962KOP', 6, 'VELOS', '2025-08-02', '390.000.000', '2025-08-02 15:21:04.201');

INSERT INTO after_sales_raw (service_ticket, vin, customer_id, model, service_date, service_type, created_at) VALUES
('T124-kgu1', 'MAS8160POE', 3, 'RANGGO', '2025-07-11', 'BP', '2025-07-11 09:24:40.012'),
('T560-jga1', 'JLK1368KDE', 4, 'INNAVO', '2025-08-04', 'PM', '2025-08-04 10:12:54.003'),
('T521-oai8', 'POI1059IIK', 5, 'RAIZA', '2026-09-10', 'GR', '2026-09-10 12:45:02.391');

-- verifikasi data masuk##########################################
SELECT * FROM customers_raw;
SELECT * FROM sales_raw;
SELECT * FROM after_sales_raw;
SELECT * FROM customer_addresses_raw;

-- Bikin layer clean#####################################################
USE maju_jaya_dw;

CREATE OR REPLACE VIEW customers_clean AS
SELECT
    id,
    name,
    CASE
        WHEN dob = '1900-01-01' THEN NULL
        WHEN dob REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(dob, '%Y-%m-%d')
        WHEN dob REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN STR_TO_DATE(dob, '%Y/%m/%d')
        WHEN dob REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(dob, '%d/%m/%Y')
        ELSE NULL
    END AS dob_clean,
    created_at
FROM customers_raw;

CREATE OR REPLACE VIEW sales_clean AS
SELECT
    vin,
    customer_id,
    model,
    invoice_date,
    CAST(REPLACE(price, '.', '') AS UNSIGNED) AS price,
    created_at
FROM sales_raw;

CREATE OR REPLACE VIEW after_sales_clean AS
SELECT
    service_ticket,
    vin,
    customer_id,
    model,
    service_date,
    service_type,
    created_at
FROM after_sales_raw;

CREATE OR REPLACE VIEW customer_addresses_clean AS
SELECT
    id,
    customer_id,
    TRIM(address) AS address,
    UPPER(TRIM(city)) AS city,
    UPPER(TRIM(province)) AS province,
    created_at
FROM customer_addresses_raw;

-- Cek Hasil Cleaning#####################################################
SELECT * FROM customers_clean;
SELECT * FROM sales_clean;
SELECT * FROM customer_addresses_clean;

-- Bikin table datamart#####################################################
USE maju_jaya_dw;

DROP TABLE IF EXISTS dm_sales_summary;
DROP TABLE IF EXISTS dm_service_priority;

CREATE TABLE dm_sales_summary (
    periode VARCHAR(7),
    class VARCHAR(20),
    model VARCHAR(100),
    total BIGINT
);

CREATE TABLE dm_service_priority (
    periode VARCHAR(4),
    vin VARCHAR(50),
    customer_name VARCHAR(255),
    address VARCHAR(255),
    count_service INT,
    priority VARCHAR(10)
);

-- Isi datamart sales summary###################################################
TRUNCATE TABLE dm_sales_summary;

INSERT INTO dm_sales_summary
SELECT
    DATE_FORMAT(invoice_date, '%Y-%m') AS periode,
    CASE
        WHEN price >= 100000000 AND price < 250000000 THEN 'LOW'
        WHEN price >= 250000000 AND price <= 400000000 THEN 'MEDIUM'
        WHEN price > 400000000 THEN 'HIGH'
        ELSE 'UNCLASSIFIED'
    END AS class,
    model,
    SUM(price) AS total
FROM sales_clean
GROUP BY
    DATE_FORMAT(invoice_date, '%Y-%m'),
    CASE
        WHEN price >= 100000000 AND price < 250000000 THEN 'LOW'
        WHEN price >= 250000000 AND price <= 400000000 THEN 'MEDIUM'
        WHEN price > 400000000 THEN 'HIGH'
        ELSE 'UNCLASSIFIED'
    END,
    model;
    
-- cek:
SELECT * FROM dm_sales_summary;
    
-- Isi datamart service priority##############################################
TRUNCATE TABLE dm_service_priority;

INSERT INTO dm_service_priority
SELECT
    DATE_FORMAT(a.service_date, '%Y') AS periode,
    a.vin,
    c.name AS customer_name,
    ca.address,
    COUNT(a.service_ticket) AS count_service,
    CASE
        WHEN COUNT(a.service_ticket) > 10 THEN 'HIGH'
        WHEN COUNT(a.service_ticket) BETWEEN 5 AND 10 THEN 'MED'
        ELSE 'LOW'
    END AS priority
FROM after_sales_clean a
LEFT JOIN customers_clean c
    ON a.customer_id = c.id
LEFT JOIN customer_addresses_clean ca
    ON a.customer_id = ca.customer_id
GROUP BY
    DATE_FORMAT(a.service_date, '%Y'),
    a.vin,
    c.name,
    ca.address;

-- cek:
SELECT * FROM dm_service_priority;