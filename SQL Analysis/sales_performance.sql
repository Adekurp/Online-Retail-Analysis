-- How is the business performing in terms of revenue, order volume, and sales value?
SELECT 
    CAST (SUM(revenue) AS DECIMAL (10, 2)) AS total_revenue,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity) AS total_units_sold,
    CAST (SUM(revenue) / COUNT(DISTINCT invoice_no) AS DECIMAL (10, 2)) AS average_order_value,
    CAST (SUM(revenue) / SUM(quantity) AS DECIMAL (10, 2)) AS average_selling_price
FROM fact_sales;

-- How does the business's sales revenue change over time, and which months generate the highest and lowest revenue?
SELECT 
    [year],
    [month],
    SUM(revenue) AS total_revenue,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity) AS total_units_sold
FROM fact_sales
GROUP BY [year], [month]
ORDER BY [year], [month];

/*
Monthly sales performance indicates that the business experiences relatively stable sales activity during the first half of the year, 
while sales activity increases toward the fourth quarter. This pattern suggests potential seasonality, 
with stronger purchasing activity toward the end of the year. The increase in Q4 could be associated with seasonal shopping behavior, 
holiday-related demand, or increased purchasing ahead of the year-end period. 
However, these are possible explanations rather than confirmed causes based on the available data.
*/
-- Which quarter generates the highest sales revenue, and what drives the differences in quarterly performance?
SELECT 
    [year],
    DATEPART(QUARTER, invoice_date) AS quarter_sales,
    CAST (SUM(revenue) AS DECIMAL (10, 2)) AS total_revenue,
    SUM(quantity) AS total_units_sold,
    COUNT(DISTINCT invoice_no) AS total_orders,
    CAST (SUM(revenue) / COUNT(DISTINCT invoice_no) AS DECIMAL (10, 2)) AS average_order_value
FROM fact_sales
WHERE [year] > 2009
GROUP BY [year], DATEPART(QUARTER, invoice_date)
ORDER BY [year], quarter_sales;

-- im excluding 2009 data because it only have data from december
/* 
Quarterly sales analysis reveals differences in revenue generation across quarters. 
Q1 records the lowest order volume but maintains a relatively high average order value, 
suggesting that its revenue performance is supported by higher-value transactions rather than a large number of orders.

In contrast, Q2 experiences an increase in order volume accompanied by a decline in average order value. 
This indicates that the additional orders generate relatively less revenue per transaction, limiting the overall revenue growth.

Q4 demonstrates the strongest performance across revenue, order volume, and average order value in the observed results. 
However, this finding should be interpreted cautiously because Q4 2011 data is incomplete, with the dataset ending on December 9, 2011.
*/
-- Which countries contribute the most to the company's revenue, and does high revenue come from more orders or higher average order value?
SELECT 
    country,
    CAST (SUM(revenue) AS DECIMAL (10, 2)) AS total_revenue,
    SUM(quantity) AS total_units_sold,
    COUNT(DISTINCT invoice_no) AS total_orders,
    CAST (SUM(revenue) / COUNT(DISTINCT invoice_no) AS DECIMAL (10, 2)) AS average_order_value,
    COUNT(DISTINCT customer_id) AS total_unique_customer
FROM fact_sales
GROUP BY country
ORDER BY total_revenue DESC;


/*
Geographical sales analysis shows that the United Kingdom is the company's dominant market, 
contributing approximately 85% of total revenue. This indicates a strong dependence on the domestic market, 
while international sales represent a considerably smaller share.

Among international markets, EIRE, the Netherlands, Germany, and France are the largest contributors to revenue. 
However, their revenue-generation patterns differ. Germany and France generate sales through relatively higher order volumes, 
whereas the Netherlands and Australia demonstrate higher average order values despite having fewer orders.

The Netherlands records the highest average order value among the countries analyzed. 
However, its relatively low order volume suggests that high-value transactions, rather than frequent purchases, 
contribute to its performance. Similar patterns can be observed in smaller markets such as Singapore, 
where a high AOV is based on a limited number of orders.

Overall, the results suggest that the business has a highly concentrated domestic revenue base, 
while international markets demonstrate different purchasing characteristics. 
These differences could help inform market expansion and customer acquisition strategies.
*/
--How much of total revenue does each country contribute, and how concentrated is the company's revenue?
SELECT
    country,
    SUM(revenue) as total_revenue,
    CAST(
        100.0 * SUM(revenue) /
        SUM(SUM(revenue)) OVER ()
        AS DECIMAL(10,2)
    ) AS revenue_contribution_pct,
    RANK()OVER(ORDER BY SUM(revenue) DESC) AS revenue_rank
FROM fact_sales
GROUP BY country
ORDER BY revenue_rank;
/*
Geographical revenue analysis reveals a significant concentration of sales in the United Kingdom, 
which contributes approximately 85% of total revenue. In comparison, international markets collectively account for only around 15%, 
indicating a strong dependence on the domestic market.

Among the international markets, EIRE, the Netherlands, Germany, and France are the largest revenue contributors. 
These markets demonstrate different purchasing characteristics. The Netherlands records a particularly high average order value despite
relatively low order volume, while Germany generates higher revenue through a greater number of orders.

These findings suggest an opportunity to strengthen the company's existing international presence, 
particularly in its leading international markets. Rather than pursuing expansion across all countries equally, 
the business could prioritize markets with established sales activity and investigate opportunities to increase order frequency, 
customer engagement, and revenue.

However, further investigation into customer purchasing behavior, market growth, and operational costs would be necessary 
before making investment decisions.
*/
