-- validate number of row across the tables
SELECT 
    'fact_sales' AS table_name,
    count(*) as total_row_fact_sales,
    count(customer_id) as total_non_null_cust_fact_sales 
FROM fact_sales

UNION ALL

SELECT
    'fact_adjustments' AS table_name,
    count(*) as total_row_fac_adjustments,
    count(customer_id) as total_non_null_cust_fact_adjustments
    
FROM fact_adjustments

UNION ALL 

SELECT 
    'raw_transactions' AS table_name,
    count(*) as total_row_raw_transactions,
    count(customer_id) as total_non_null_cust_raw_transactions 
FROM raw_transactions;

-- checked the tables value, and detailed table structures
SELECT TOP 10 * FROM fact_sales;
EXEC sp_help fact_sales;

SELECT TOP 10 * FROM fact_adjustments;
EXEC sp_help fact_adjustments;


SELECT TOP 10 * FROM raw_transactions;
EXEC sp_help raw_transactions;

-- validate the transaction classification records
SELECT
    transaction_status,
    count(*) as total_records,
    sum(quantity) as total_quantity,
    sum(revenue) as total_revenue
FROM raw_transactions
GROUP BY transaction_status
ORDER BY total_records DESC

-- validate total records, and revenue across table
-- and reconcile the total_revenue in fact tables with the raw transcation total_revenue
SELECT
    'fact sales' as table_name,
    count(*) as total_records,
    sum(revenue) as total_revenue
FROM fact_sales

UNION ALL

SELECT
    'fact adjustments' as table_name,
    COUNT(*) as total_records,
    sum(revenue) as total_revenue
FROM fact_adjustments

UNION ALL

SELECT
    'raw transactions' as table_name,
    count(*) as total_records,
    sum(revenue) as total_revenue
FROM raw_transactions

SELECT
    count(*) as total_records,
    count(*) - count(DISTINCT CONCAT(
        invoice_no, '|',
        stock_code, '|',
        quantity, '|',
        invoice_date, '|',
        price, '|',
        COALESCE(customer_id, '')
    )) as potential_duplicate_records
FROM raw_transactions

-- checking the data date range
SELECT
    MIN(invoice_date) AS first_transaction,
    MAX(invoice_date) AS last_transaction,
    COUNT(DISTINCT year_month) AS distinct_year_months
FROM raw_transactions;

-- checking missing values
SELECT
    sum(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) as missing_customer_id,
    sum(CASE WHEN descriptions IS NULL THEN 1 ELSE 0 END) as missing_descriptions,
    sum(CASE WHEN invoice_date IS NULL THEN 1 ELSE 0 END) as missing_invoice_date,
    sum(CASE WHEN invoice_no IS NULL THEN 1 ELSE 0 END) as missing_invoice_no
FROM raw_transactions;

-- Checking is there any EXACT duplicate values
WITH potential_duplicates AS (
    SELECT
        *,
        COUNT(*) OVER (
            PARTITION BY
                invoice_no,
                stock_code,
                quantity,
                invoice_date,
                price,
                customer_id
        ) AS duplicate_count
    FROM raw_transactions
)
SELECT 
    *
FROM potential_duplicates
WHERE duplicate_count > 1
ORDER BY invoice_no, stock_code;

SELECT
    invoice_no,
    stock_code,
    descriptions,
    quantity,
    invoice_date,
    price,
    customer_id,
    country,
    revenue,
    is_cancelled,
    is_negative_quantity,
    year,
    month,
    year_month,
    day_name,
    hour,
    is_bad_debt,
    is_zero_price,
    transaction_status,
    COUNT(*) AS duplicate_count
FROM raw_transactions
GROUP BY
    invoice_no,
    stock_code,
    descriptions,
    quantity,
    invoice_date,
    price,
    customer_id,
    country,
    revenue,
    is_cancelled,
    is_negative_quantity,
    year,
    month,
    year_month,
    day_name,
    hour,
    is_bad_debt,
    is_zero_price,
    transaction_status
HAVING COUNT(*) > 1;
/*
Duplicate validation i identified two pairs of records sharing the same invoice, stock code, quantity, date, price, and customer. 
However, their descriptions is different. A full row comparison identified no exact duplicate records. 
Therefore, all records were retained to preserve transaction-level data integrity.
*/


-- Validate fact sales records
SELECT
    COUNT(*) AS total_records,
    SUM(revenue) as total_revenue,
    SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END)
        AS non_positive_quantity,
    SUM(CASE WHEN price <= 0 THEN 1 ELSE 0 END)
        AS non_positive_price
FROM fact_sales;

-- validate fact adjustments records
SELECT
    transaction_status,
    COUNT(*) AS total_records,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue
FROM fact_adjustments
GROUP BY transaction_status
ORDER BY transaction_status;

-- Double checked missing classification
SELECT
    SUM(CASE WHEN transaction_status IS NULL THEN 1 ELSE 0 END)
        AS missing_status,
    SUM(CASE WHEN transaction_status NOT IN (
        'Bad Debt',
        'Cancellation',
        'Return / Negative Quantity'
    ) THEN 1 ELSE 0 END) AS unexpected_status
FROM fact_adjustments;


