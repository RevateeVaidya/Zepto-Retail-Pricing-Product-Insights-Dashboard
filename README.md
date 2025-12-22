# Zepto Retail Pricing & Product Insights
This repository contains an end-to-end data analytics project focused on analyzing Zepto’s retail product catalog. The project explores pricing trends, discount strategies, customer ratings, and product value segmentation to identify budget-friendly and premium offerings.
The workflow includes data cleaning and transformation using Python, structured analysis using PostgreSQL, and interactive dashboard creation using Power BI. Key insights include the dominance of budget products, strong value offered by fresh produce categories, and consistent customer ratings across price segments.

## Objectives:
* Analyze pricing and discount trends across product categories
* Compare product value using standardized pricing (price per 100g)
* Segment products into Premium and Budget categories
* Visualize insights through interactive Power BI dashboards
* Generate actionable business insights for retail pricing strategy

## Tools & Technologies:
* Python (pandas) – data cleaning & preprocessing
* Excel - data cleaning & preprocessing
* PostgreSQL – SQL analysis & transformations
* Power BI – dashboarding & visualization

## Dataset Description
* Total Products: 765
* Total Categories: 15
* Data Type: Retail product-level data
* Key Fields:
 category | product_name | price | packsize | rating | original_price | discount

## Data Cleaning & Preparation
Data cleaning was performed using Python (pandas) and Excel to handle inconsistencies and prepare the dataset for analysis.

Key Cleaning Steps:
* Standardized pack sizes by extracting quantity and unit
* Handled mixed units (g, kg, pc)
* Cleaned pack size ranges (e.g., 600–800 g → 600 g)
* Calculated unit-level pricing
* Created standardized pricing metric: price per 100g
* Computed discount percentage safely

**Key Formulas Used:**
```
Unit Price = Price / Quantity
Price per 100g = Unit Price × 100
Discount % = ((Original Price − Price) / Original Price) × 100
```

## Database & SQL Analysis
The cleaned dataset was loaded into PostgreSQL for structured analysis.

**Table Created:**
zepto_products

**Key SQL Transformations:**
* Aggregations (AVG, COUNT)
* Category-wise analysis
* Top-N product identification
* Premium vs Budget segmentation using CASE logic

Premium vs Budget Logic:
```
CASE 
  WHEN price_per_100g > (
      SELECT AVG(price_per_100g)
      FROM zepto_products
      WHERE unit = 'g'
  )
  THEN 'Premium'
  ELSE 'Budget'
END AS value_label
```

## Dashboard Design (Power BI)
###**Page 1 – Product Overview**
Purpose: High-level understanding of the product catalog

Visuals Included:
* KPI cards (Total Products, Avg Price, Avg Rating, Avg Discount, etc.)
* Products per Category
* Average Rating per Category
* Product Details Table

###**Page 2 – Pricing & Value Analysis**
Purpose: Identify value-driven and premium pricing patterns

Visuals Included:
* Premium vs Budget Product Split
* Top 10 Cheapest Products per 100g
* Top 10 Premium Products (Most Expensive per 100g)
* Top 10 Highest Rated Products
* Average Price per 100g by Category
* Summary Insight Text Box

## Key Insights
* Budget products dominate ~69% of the catalog, indicating a value-oriented pricing strategy.
* Fresh produce categories offer the lowest price per 100g, making them the most cost-effective.
* Premium pricing is driven by packaged, skincare, and specialty products.
* Customer ratings remain consistently high across both premium and budget segments, suggesting price does not strongly impact perceived quality.


