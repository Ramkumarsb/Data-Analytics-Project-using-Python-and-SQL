-- View all records from df_orders
SELECT * FROM df_orders;

-- Find top 10 highest revenue-generating products
SELECT TOP 10 
    product_id, 
    SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY product_id
ORDER BY total_sales DESC;

-- Find top 5 highest-selling products in each region
WITH cte AS (
    SELECT 
        region, 
        product_id, 
        SUM(sale_price) AS total_sales
    FROM df_orders
    GROUP BY region, product_id
)
SELECT region, product_id, total_sales
FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY region ORDER BY total_sales DESC) AS rn
    FROM cte
) A
WHERE rn <= 5
ORDER BY region, total_sales DESC;

-- Find month-over-month growth comparison for 2022 and 2023 sales
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year, 
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS total_sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_month AS Month,
    SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS Sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) AS Sales_2023,
    SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) - 
    SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS Growth_Amount,
    ROUND(
        (SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) - 
         SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END)) * 100.0 / 
        NULLIF(SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END), 0), 2
    ) AS Growth_Percentage
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- Find the highest sales month for each category
WITH cte AS (
    SELECT 
        category, 
        FORMAT(order_date, 'yyyyMM') AS order_year_month,
        SUM(sale_price) AS total_sales
    FROM df_orders
    GROUP BY category, FORMAT(order_date, 'yyyyMM')
)
SELECT category, order_year_month, total_sales
FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY category ORDER BY total_sales DESC) AS rn
    FROM cte
) A
WHERE rn = 1
ORDER BY category, total_sales DESC;

-- Identify the sub-category with the highest growth in profit from 2022 to 2023
WITH cte AS (
    SELECT 
        sub_category, 
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS total_sales
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
),
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS Sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) AS Sales_2023
    FROM cte
    GROUP BY sub_category
)
SELECT TOP 1 
    sub_category,
    Sales_2022,
    Sales_2023,
    (Sales_2023 - Sales_2022) AS Growth_Amount,
    ROUND(
        (Sales_2023 - Sales_2022) * 100.0 / NULLIF(Sales_2022, 0), 2
    ) AS Growth_Percentage
FROM cte2
ORDER BY Growth_Amount DESC;
