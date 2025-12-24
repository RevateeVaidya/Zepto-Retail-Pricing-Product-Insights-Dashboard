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

### 🧹 Data Cleaning & Preparation – using Python

#### 1. Overview
This document explains the Python-based data cleaning process applied to the Zepto retail dataset.  
The focus of this step was to standardize inconsistent pack size formats and extract reliable numeric values required for pricing and value analysis.

The cleaned dataset was later used for SQL analysis and Power BI dashboard creation.

---

#### 2. Libraries Used

```python
import pandas as pd
import re
```

Purpose:
* pandas is used for reading, transforming, and exporting tabular data.
* re (regular expressions) is used to extract numeric values from text-based pack size fields.

#### 3. Loading the Dataset
```
df = pd.read_excel(r"C:\Users\revat\OneDrive\Documents\Zepto_data1.xlsx")
```
Explanation:
* Loads the raw Zepto product data from an Excel file into a pandas DataFrame.
* The dataset contains inconsistent pack size formats that require cleaning.

#### 4. Pack Size Parsing Function
```
def parse_packsize(text):
    """Return (quantity, unit) from a Packsize string."""
    if pd.isna(text):
        return None, None

    s = str(text).lower()

    nums = re.findall(r'\d+(?:\.\d+)?', s)
    if not nums:
        return None, None

    if "pc" in s or "pcs" in s or "piece" in s or "pack" in s:
        qty = float(nums[0])
        return qty, "pc"

    if "kg" in s:
        grams = float(nums[0]) * 1000
        return grams, "g"

    if "mg" in s:
        mg = float(nums[0])
        return mg, "mg"

    if "ml" in s:
        ml = float(nums[0]) if len(nums) == 1 else (float(nums[0]) + float(nums[1])) / 2
        return ml, "ml"

    if " l" in s:
        ml = float(nums[0]) * 1000
        return ml, "ml"

    if "gm" in s or "g" in s:
        grams = float(nums[0]) if len(nums) == 1 else (float(nums[0]) + float(nums[1])) / 2
        return grams, "g"

    return float(nums[0]), "unknown"
```
#### 5. Logic Breakdown
```
if pd.isna(text):
    return None, None
```
Prevents errors when pack size data is missing.

#### 5.2 Standardizing Text

```
s = str(text).lower()
```
Converts all pack size text to lowercase for consistent pattern matching.

#### 5.3 Extracting Numbers Using Regex
```
nums = re.findall(r'\d+(?:\.\d+)?', s)
```
* Extracts numeric values (including decimals) from pack size strings.
* Handles formats like:
* 600 - 800 g
* 1.5 kg
* 250 ml

#### 6. Unit-Specific Parsing Rules
Pieces / Packs (pc, pcs, pack)
Uses the first numeric value.
Standardizes unit to pc.
Example:
4 pcs → quantity = 4, unit = pc

* Kilograms (kg)
Converts kilograms to grams.
Example:
1 kg → 1000 g

* Milligrams (mg)
Retains milligram values without conversion.

* Milliliters & Liters (ml, l)
Uses the average for ranges.
Converts liters to milliliters.
Examples:
200–300 ml → 250 ml
1 l → 1000 ml

* Grams (g, gm)
Uses the average when a range is present.
Standardizes all values to grams.
Example:
600–800 g → 700 g

* Fallback Case
```
return float(nums[0]), "unknown"
```
Handles unexpected formats safely without losing numeric data.

#### 7. Applying the Cleaning Function
```
df[['quantity', 'unit']] = df['Packsize'].apply(
    lambda x: pd.Series(parse_packsize(x))
)
```
* Explanation:
Applies the parsing function to every row in the Packsize column.

* Creates two new columns:
* quantity
* unit

#### 8. Data Validation
```
print(df.head())
print(df.columns)
print(df[['Packsize', 'quantity', 'unit']].head(10))
```
* Purpose:
* Verifies correct extraction of quantity and unit.
* Ensures no unexpected nulls or incorrect conversions.

#### 9. Exporting the Cleaned Dataset
```
output_path = r"C:\Users\revat\OneDrive\Documents\Zepto_data1_processed.xlsx"
df.to_excel(output_path, index=False)
```
* Explanation:
Saves the cleaned dataset for downstream usage.
* This file is used for:
* PostgreSQL database ingestion
* SQL analysis
* Power BI dashboards

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
### **Page 1 – Product Overview**
Purpose: High-level understanding of the product catalog

Visuals Included:
* KPI cards (Total Products, Avg Price, Avg Rating, Avg Discount, etc.)
* Products per Category
* Average Rating per Category
* Product Details Table

### **Page 2 – Pricing & Value Analysis**
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


