# Reseller Segmentation using RFM Analysis

## Overview

This project performs **RFM (Recency, Frequency, Monetary) Analysis** to segment resellers based on their purchasing behavior. The analysis categorizes resellers into different reseller segments, helping businesses identify valuable resellers and strategize marketing efforts.

## Dataset

The analysis is performed using the `FactResellerSales` table, which contains transactional data related to reseller purchases.

**Source:** `AdventureWorksDW2022` which you can download [here](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms)

## Tools Used

- **SQL Server Management Studio (SSMS)** for querying and data processing.
- **Power BI** for data visualization and insights.

## Data Cleaning and Preparation

- Removing duplicate transactions.
- Handling missing values in `OrderDate`, `SalesAmount`, or `SalesOrderNumber`.
- Ensuring date formats are correct for `OrderDate`.
- Aggregating transactions per reseller.

## Exploratory Data Analysis (EDA)

- Analyzing the distribution of `SalesAmount`, `OrderDate`, and `SalesOrderNumber`.
- Identifying trends in reseller purchasing behavior.
- Checking for outliers that might affect segmentation.

## Data Analysis

The following segment demonstrates how to use `NTILE(5)` for segmentation in SQL, which evenly distributes data across 5 groups.
```sql
-- Recency Calculation
DROP TABLE IF EXISTS #Recency_Category;
SELECT
    ResellerKey,
    DATEDIFF(DAY, MAX(OrderDate), MIN(OrderDate)) AS GapDay,
    NTILE(5) OVER (ORDER BY DATEDIFF(DAY, MAX(OrderDate), MIN(OrderDate)) DESC) AS Recency
INTO #Recency_Category
FROM FactResellerSales
GROUP BY ResellerKey;
```

## Application

- Identifying **high-value customers** to enhance loyalty programs.
- Targeting **at-risk customers** with special promotions.
- Prioritizing **recent buyers** for follow-up marketing campaigns.
- Allocating resources more effectively based on customer value.

## Recommendations

- **Personalized Marketing**: Use RFM segments to tailor email campaigns, discounts, or loyalty rewards.
- **Customer Retention Strategies**: Implement engagement strategies for "At Risk" and "Hibernating" customers.
- **Optimizing Customer Acquisition**: Identify behaviors of high-value customers and find similar prospects.

## Limitations

- **Static Analysis**: The results are based on historical data and may not reflect future trends.
- **No Customer Sentiment Data**: This model does not account for qualitative feedback from customers.
- **Threshold Sensitivity**: Changing NTILE segmentation may impact the classification results.

---

## How to Use

- Run the SQL script in **SQL Server** with the `AdventureWorksDW2022` database.
- Modify the reference date (`MIN(OrderDate)`) as needed.
- Customize segmentation rules based on business needs.

---

If you find this project useful, feel free to ⭐ the repository and contribute with improvements!

📌 **Author:** Nguyễn Hoàng Gia Phúc
📧 **Contact:** nguyenhoanggiaphucwork@gmail.com

