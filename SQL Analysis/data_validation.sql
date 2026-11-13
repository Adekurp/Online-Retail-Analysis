SELECT TOP 10 * FROM fact_sales;
EXEC sp_help fact_sales;
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


SELECT TOP 10 * FROM fact_adjustments;
EXEC sp_help fact_adjustments;


SELECT TOP 10 * FROM raw_transactions;
EXEC sp_help raw_transactions;

