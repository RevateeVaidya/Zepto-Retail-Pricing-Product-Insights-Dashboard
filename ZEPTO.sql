/* Project: Zepto Retail Pricing & Product Insights

Description:
This SQL script contains queries used to analyze Zepto’s retail product catalog.
The queries support pricing analysis, discount evaluation, customer rating insights,
and value segmentation (Premium vs Budget).

Purpose:
- Validate and explore product-level data
- Perform category-wise aggregations
- Identify best-value and premium products using price per 100g
- Prepare datasets for Power BI dashboards

Database:
PostgreSQL

Table Used:
zepto_products
*/




--1) Table Creation – zepto_products
--Creates the main table to store cleaned and transformed Zepto product data.
--The table is designed to support pricing analysis, unit-level comparisons, discount calculations, and value segmentation.

CREATE TABLE zepto_products (
    category TEXT,
    product_name TEXT,
    price NUMERIC(10,2),
    packsize TEXT,
    quantity NUMERIC(10,2),
    unit TEXT,
    unit_price NUMERIC(10,4),
    rating NUMERIC(10,2),
    original_price NUMERIC(10,2),
    discount NUMERIC(10,2),
    discount_percentage NUMERIC(10,2),
    price_per_100g NUMERIC(10,2)
);

--Key Design Choices:
--NUMERIC data types used for pricing accuracy
--Separate fields for quantity and unit to enable standardized pricing
-- price_per_100g added for fair cross-product comparison



--2)Data Validation – Sample Records
--Used to quickly validate that data has been loaded correctly into the database and to visually inspect column values after ingestion.
SELECT * FROM zepto_products LIMIT 10;  



--3)Total Product Count
--Calculates the total number of products available in the dataset.
--This metric is used directly in KPI cards on the dashboard.
SELECT COUNT(*) 
AS total_products
FROM zepto_products;



--4️)Distinct Category Count
--Determines how many unique product categories exist in the catalog, helping assess the breadth of assortment.
SELECT 
    COUNT(DISTINCT category) 
	AS distinct_categories
FROM zepto_products;



--5)Top 10 most expensive products (by Price).
--Identifies the highest-priced products based on absolute price.
--Used to highlight premium-priced items and outliers in pricing.
SELECT product_name, 
       category, 
	   price
from zepto_products
ORDER BY price DESC
LIMIT 10;



--6)Top 10 cheapest products (by Price_per_100g).
--Finds the most cost-effective products using standardized pricing (price_per_100g).
--Filtering by unit = g ensures fair comparison across products.
SELECT product_name,
       price, 
	   price_per_100g
FROM zepto_products
      WHERE price_per_100g <> 0 
      AND unit = 'g'
ORDER BY price_per_100g ASC
LIMIT 10;



--7)The average discount percentage for each category.
--Analyzes discount behavior across categories to identify where promotional strategies are most aggressive.
SELECT category, 
	AVG(discount_percentage) as AVG_discount_percentage
FROM zepto_products
GROUP BY category
ORDER BY AVG_discount_percentage DESC;



--8)Products where price is lower than original_price.
--Identifies products currently being sold below their original price, highlighting discounted items.
SELECT product_name, 
	   price, 
	   original_price, 
	   discount_percentage
FROM zepto_products
WHERE price < original_price;



--9)Category-wise Product Summary
--Provides a category-level summary combining volume, pricing, and customer satisfaction.
--Used to compare category performance holistically
SELECT category, 
       count(product_name) as Number_of_products, 
       AVG(price) as Avg_price, 
       AVG(rating) as Avg_rating
FROM zepto_products
Group by category
Order by Avg_rating DESC;



--10)Best value products (per 100g)
--Identifies the top value-for-money products based on lowest standardized price per 100g.
SELECT product_name, 
       category, 
	   price_per_100g
FROM zepto_products
WHERE unit = 'g'
ORDER BY price_per_100g ASC
LIMIT 15;



--11)Premium vs budget products segmentation
--Segments products into 'Premium' and 'Budget' based on whether their price_per_100g is above or below the average price_per_100g.
--This segmentation supports value-based analysis and dashboard visualizations.
SELECT
    product_name,
    category,
    price_per_100g,
    CASE 
        WHEN price_per_100g > (
            SELECT AVG(price_per_100g)
            FROM zepto_products
            WHERE unit = 'g'
        ) 
        THEN 'Premium'
        ELSE 'Budget'
    END AS value_label
FROM zepto_products
WHERE unit = 'g'
ORDER BY price_per_100g;



--12)Top 10 Premium Products (by price_per_100g)
--Lists the top 10 most expensive 'Premium' products based on price_per_100g.
--Extracts the most expensive premium products using standardized pricing, helping identify high-margin or niche items.
WITH value_segment AS (
    SELECT
        product_name,
        category,
        price_per_100g,
        rating,
        CASE 
            WHEN price_per_100g > (
                SELECT AVG(price_per_100g)
                FROM zepto_products
                WHERE unit = 'g'
            ) THEN 'Premium'
            ELSE 'Budget'
        END AS value_label
    FROM zepto_products
    WHERE unit = 'g'
)
SELECT
    product_name,
    category,
    price_per_100g,
    rating
FROM value_segment
WHERE value_label = 'Premium'
ORDER BY price_per_100g DESC
LIMIT 10;



--13)Category-wise Value Score
--Aggregates pricing and rating metrics at the category level to evaluate overall value performance.
--Used to rank categories from best to worst value.
WITH value_segment AS (
    SELECT
        product_name,
        category,
        price_per_100g,
        rating,
        CASE 
            WHEN price_per_100g > (
                SELECT AVG(price_per_100g)
                FROM zepto_products
                WHERE unit = 'g'
            ) THEN 'Premium'
            ELSE 'Budget'
        END AS value_label
    FROM zepto_products
    WHERE unit = 'g'
)
SELECT
    category,
    AVG(price_per_100g) AS avg_price_per_100g,
    AVG(rating)         AS avg_rating,
    COUNT(*)            AS total_products
FROM value_segment
GROUP BY category
ORDER BY avg_price_per_100g ASC;



--14)Price vs Rating Dataset (Filtered)
--Prepares a cleaned dataset for analyzing the relationship between price, rating, and value segmentation, while removing extreme outliers.
SELECT
    category,
    price,
    rating,
    price_per_100g,
    discount_percentage,
    CASE 
        WHEN price_per_100g > (
            SELECT AVG(price_per_100g)
            FROM zepto_products
            WHERE unit = 'g'
        ) THEN 'Premium'
        ELSE 'Budget'
    END AS value_label
FROM zepto_products
WHERE
    unit = 'g'
    AND price_per_100g IS NOT NULL
    AND price_per_100g > 0
    AND price_per_100g < 200;   

    

---15)TOP 10 highest Rating products
--Identifies products with the highest customer ratings, highlighting top-performing and well-received items regardless of price.
SELECT product_name,
	   category,
	   rating
FROM zepto_products
ORDER BY rating DESC
LIMIT 10;



--These SQL queries collectively support descriptive, comparative, and value-based analysis, forming the analytical foundation for the Power BI dashboards.