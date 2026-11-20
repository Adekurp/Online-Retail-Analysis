-- Which countries have the strongest customer purchasing activity, based on identifiable customers and their order behavior?
SELECT
    country,
    COUNT(DISTINCT customer_id) as total_unique_customer,
    count(DISTINCT invoice_no) as total_orders,
    cast(1.0 * COUNT(DISTINCT invoice_no)/COUNT(DISTINCT customer_id) AS decimal (18,2)) as avg_orders_per_customer,
    sum(revenue) AS total_revenue_from_identified_customer,
    CAST(SUM(revenue) / COUNT(DISTINCT customer_id) as decimal (18,2)) as revenue_per_customer 
FROM fact_sales
WHERE customer_id IS NOT NULL
GROUP BY country
ORDER BY total_revenue_from_identified_customer DESC;
/*
The UK is the company's primary customer market, generating £14.39 million from 5,350 identifiable customers. 
The main business priority should be retaining and strengthening the UK customer base, 
while investigating high-value international markets is needed, such as EIRE and the Netherlands to understand their growth potential.
*/

-- Who are the top 10 customers contributing the most revenue to the business?
SELECT TOP 10
    customer_id,
    CAST(SUM(revenue) as decimal (10,2)) as total_revenue,
    COUNT(DISTINCT invoice_no) as total_orders,
    SUM(quantity) as total_units_purchased,
    CAST(SUM(revenue)/COUNT(DISTINCT invoice_no) as decimal (10,2)) as average_order_value
FROM fact_sales
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY total_revenue DESC;

/*
The top 10 customers generated approximately £2.79 million in combined revenue. Customer 18102 contributed the highest revenue (£580,987.04), 
while customer 14911 had the highest purchasing frequency with 398 orders. 
Customer 16446 stood out with only two orders but an exceptionally high AOV of £84,236.25.

That means high customer value comes from different purchasing behaviors. 
The business should focus on retaining high-revenue customers while understanding the purchasing patterns behind their contributions.
*/

-- How many customers make repeat purchases, and how much revenue do they generate compared with one-time customers?
WITH customer_segments AS(
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) as orders,
        SUM(revenue) as revenue,
        CASE 
            WHEN COUNT(DISTINCT invoice_no) = 1 THEN 'one time customer'
            ELSE 'repeat customer'
        END as customer_type
    FROM fact_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    customer_type,
    count(customer_id) as total_cust,
    CAST((100.0 * COUNT(customer_type)/SUM(COUNT(customer_type)) OVER()) as decimal (10,2)) AS pct_total_cust,
    sum(orders) as total_orders,
    cast(sum(revenue) as decimal (10,2)) as total_revenue,
    CAST((100.0 * sum(revenue)/SUM(SUM(revenue)) OVER()) as decimal (10,2)) AS pct_total_revenue
FROM customer_segments
GROUP BY customer_type
ORDER BY total_revenue DESC;
/*
The analysis identified 5,878 customers, of which 4,255 (72.39%) were repeat customers and 1,623 (27.61%) were one-time customers. 
Repeat customers generated £16.81 million in revenue, contributing 96.78% of total revenue from identifiable customers. 
Whereas one-time customers contributed £560,272.56, or 3.22% of the revenue.

The key business takeaway is that repeat customers are the primary revenue contributors. 
The business should prioritize retaining existing repeat customers,
while exploring opportunities to convert one-time buyers into repeat purchasers.
*/

-- How frequently do customers purchase from the business, and how is revenue distributed across different purchasing-frequency groups?
WITH purchase_groups AS(
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) as orders,
        SUM(revenue) as revenue,
        CASE
            WHEN COUNT(DISTINCT invoice_no) = 1 THEN 'one time'
            WHEN COUNT(DISTINCT invoice_no) >= 2 AND COUNT(DISTINCT invoice_no) <= 5 THEN 'occasional'
            WHEN COUNT(DISTINCT invoice_no) >= 6 AND COUNT(DISTINCT invoice_no) <= 10 THEN 'regular'
            WHEN COUNT(DISTINCT invoice_no) >= 11 AND COUNT(DISTINCT invoice_no) <= 20 THEN 'frequent'
            WHEN COUNT(DISTINCT invoice_no) >= 21 THEN 'very frequent'
        END as purchase_freq_groups
    FROM fact_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    purchase_freq_groups,
    COUNT(customer_id) as total_cust,
    CAST((100.0 * COUNT(purchase_freq_groups)/SUM(COUNT(purchase_freq_groups)) OVER()) as decimal (10,2)) AS pct_total_cust,
    SUM(orders) as total_orders,
    CAST(SUM(revenue) as decimal (10,2)) as total_revenue,
    CAST((100.0 * sum(revenue)/SUM(SUM(revenue)) OVER()) as decimal (10,2)) AS pct_total_revenue
FROM purchase_groups
GROUP BY purchase_freq_groups
ORDER BY total_revenue DESC;