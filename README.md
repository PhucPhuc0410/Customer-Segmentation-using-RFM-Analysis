# Reseller Segmentation using RFM Analysis

---

## Overview

This project performs **RFM (Recency, Frequency, Monetary) Analysis** to segment resellers based on their purchasing behavior. The analysis categorizes resellers into different reseller segments, helping businesses identify valuable resellers and strategize marketing efforts.

## Dataset

The analysis is performed using the `FactResellerSales` table, which contains transactional data related to reseller purchases.

**Source:** `AdventureWorksDW2022` which you can download [here](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms)

## Tools Used

- **SQL Server Management Studio (SSMS)** for querying and data processing.
- **Power BI** for data visualization and insights.
- **Python** for querying and data processing, and data visualization.

*Even though SQL and Power BI are sufficient for these tasks. However, I incorporated Python to expand the project scope.*

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

I use percentiles, specifically quintiles, to segment data in SQL, ensuring an even distribution into five groups. This helps create more meaningful reseller categories.

In SQL Server, I use `CUME_DIST()`:
```sql
-- Recency Calculation
DROP TABLE IF EXISTS #Recency_Category
SELECT
	ResellerKey,
	DATEDIFF(DAY, MAX(OrderDate), '2013-11-29') GapDay,
	CUME_DIST() OVER (ORDER BY DATEDIFF(DAY, MAX(OrderDate), '2013-11-29') DESC) AS Recency_Score,
    CASE 
        WHEN CUME_DIST() OVER (ORDER BY DATEDIFF(DAY, MAX(OrderDate), '2013-11-29') DESC) <= 0.2 THEN 1
        WHEN CUME_DIST() OVER (ORDER BY DATEDIFF(DAY, MAX(OrderDate), '2013-11-29') DESC) <= 0.4 THEN 2
        WHEN CUME_DIST() OVER (ORDER BY DATEDIFF(DAY, MAX(OrderDate), '2013-11-29') DESC) <= 0.6 THEN 3
        WHEN CUME_DIST() OVER (ORDER BY DATEDIFF(DAY, MAX(OrderDate), '2013-11-29') DESC) <= 0.8 THEN 4
        ELSE 5
    END AS Recency
INTO #Recency_Category
FROM FactResellerSales
GROUP BY ResellerKey;
```

![image](https://github.com/user-attachments/assets/7fd5c93a-a3f8-4fbb-8235-1cc212aba9b8)

In SQL Server, I also use another approach, which is using `NTILE()`:
```sql
SELECT
	ResellerKey,
	DATEDIFF(DAY, MAX(OrderDate), '2013-11-29') GapDay,
	CUME_DIST() OVER (ORDER BY DATEDIFF(DAY, MAX(OrderDate), '2013-11-29') DESC) AS Recency_Score,
    NTILE(5) OVER (ORDER BY DATEDIFF(DAY, MAX(OrderDate), '2013-11-29') DESC) AS Recency
INTO #Recency_Category
FROM FactResellerSales
GROUP BY ResellerKey;
```

![Reseller RFM Segmentation using NTILE()](https://github.com/user-attachments/assets/ffa81df2-a1a3-40bd-a6d0-d2a6b091ffe1)

In Python, I use `pd.qcut()`:
```python
# Recency Calculation
current_date = datetime(2013, 11, 29)
df_recency = df_FactResellerSales.groupby('ResellerKey')['OrderDate'].max().reset_index()
df_recency['GapDay'] = (current_date - df_recency['OrderDate']).dt.days
df_recency['Recency'] = pd.cut(df_recency['GapDay'], 5, labels=[5, 4, 3, 2, 1], duplicates='drop')
```

![image](https://github.com/user-attachments/assets/237e6453-428f-4d40-96da-7b85c30256fd)


## Application

- Identifying **high-value customers** to enhance loyalty programs.
- Targeting **at-risk customers** with special promotions.
- Prioritizing **recent buyers** for follow-up marketing campaigns.
- Allocating resources more effectively based on customer value.

## Recommendations

- The company has successfully maintained its **Champions** reseller segment. This group consistently makes purchases, has a high average order value, and remains actively engaged.

→ The key challenge is: "How to retain and nurture these high-value resellers?". To achieve this, the company needs to focus on enhancing customer care and implementing strategies that encourage repeat purchases among these resellers.

- At the same time, the company possesses a promising **Potential Loyalist** and **Loyal Reseller* segment who purchase frequently but have a relatively lower order value.

→ A strategic approach here would be to introduce incentive programs tied to spending thresholds, encouraging them to increase their order size over time.

- On the other hand, the company has a significant number of **At Risk** and **Needing Attention** resellers - those with a moderate to high purchase frequency and decent order value but have not placed any recent transactions.

→ The potential reason behind this inactivity might be dissatisfaction with the purchasing experience. The company should conduct surveys and research to identify underlying issues and implement corrective measures promptly. However, there is still an opportunity to re-engage this group in the near future.

- Lastly, the **Hibernating**, **About to Sleep**, and **Lost** resellers form a sizable but low-value segment, characterized by weak purchasing behavior and low order value.

→ Reactivating these resellers is challenging and would require a well-defined strategy to reposition the brand and address any negative perceptions they may have.

## Limitations

- The results are based on historical data and may not reflect future trends. Regular updates are needed to track customer behavior dynamically. Modify the reference date `'2013-11-29'` as needed.
- External market trends or competitor activity are not considered in this segmentation.
- My different approaches may have some differences in results. The RFM thresholds and segmentation rules may not be universally applicable and should be adjusted based on specific business needs.

---

If you find this project useful, feel free to ⭐. Your support will be my super motivation ❤️.

📌 **Author:** Nguyễn Hoàng Gia Phúc

📧 **Contact:** nguyenhoanggiaphucwork@gmail.com

🔗 **LinkedIn:** [Nguyen Hoang Gia Phuc](https://www.linkedin.com/in/nguyenhoanggiaphuc)
