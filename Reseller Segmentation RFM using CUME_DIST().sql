USE AdventureWorksDW2022;

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

-- Frequency Calculation
DROP TABLE IF EXISTS #Frequency_Category
SELECT
	ResellerKey,
	COUNT(DISTINCT SalesOrderNumber) TotalOrder,
	CUME_DIST() OVER (ORDER BY COUNT(DISTINCT SalesOrderNumber) ASC) AS Frequency_Score,
    CASE 
        WHEN CUME_DIST() OVER (ORDER BY COUNT(DISTINCT SalesOrderNumber) ASC) <= 0.2 THEN 1
        WHEN CUME_DIST() OVER (ORDER BY COUNT(DISTINCT SalesOrderNumber) ASC) <= 0.4 THEN 2
        WHEN CUME_DIST() OVER (ORDER BY COUNT(DISTINCT SalesOrderNumber) ASC) <= 0.6 THEN 3
        WHEN CUME_DIST() OVER (ORDER BY COUNT(DISTINCT SalesOrderNumber) ASC) <= 0.8 THEN 4
        ELSE 5
    END AS Frequency
INTO #Frequency_Category
FROM FactResellerSales
GROUP BY ResellerKey;

-- Monetary Calculation
DROP TABLE IF EXISTS #Monetary_Category
SELECT
	ResellerKey,
	SUM(SalesAmount) TotalRev,
	CUME_DIST() OVER (ORDER BY SUM(SalesAmount) ASC) AS Monetary_Score,
    CASE 
        WHEN CUME_DIST() OVER (ORDER BY SUM(SalesAmount) ASC) <= 0.2 THEN 1
        WHEN CUME_DIST() OVER (ORDER BY SUM(SalesAmount) ASC) <= 0.4 THEN 2
        WHEN CUME_DIST() OVER (ORDER BY SUM(SalesAmount) ASC) <= 0.6 THEN 3
        WHEN CUME_DIST() OVER (ORDER BY SUM(SalesAmount) ASC) <= 0.8 THEN 4
        ELSE 5
    END AS Monetary
INTO #Monetary_Category
FROM FactResellerSales
GROUP BY ResellerKey;

-- Final RFM Segmentation
DROP TABLE IF EXISTS #FinalRFM
SELECT 
	r.ResellerKey,
	r.GapDay,
	f.TotalOrder,
	m.TotalRev,
	r.Recency,
	f.Frequency,
	m.Monetary,
	CONCAT(Recency, Frequency, Monetary) RFM,
	CASE  
    WHEN CONCAT(Recency, Frequency, Monetary) IN ('555', '554', '545', '544', '455', '445', '454') 
        THEN 'Champions'  
    WHEN CONCAT(Recency, Frequency, Monetary) IN ('543', '444', '435', '355', '354', '345', '344', '335')  
        THEN 'Loyal Customers' 
    WHEN CONCAT(Recency, Frequency, Monetary) IN ('553', '551', '552', '541', '542', '533', '532', '531', '452', '451', '442', '441', '431', '453', '433', '432', '423', '353', '352', '351', '342', '341', '333', '323')  
        THEN 'Potential Loyalist'  
    WHEN CONCAT(Recency, Frequency, Monetary) IN ('512', '511', '422', '421', '412', '411', '311')  
        THEN 'Recent Customers'  
    WHEN CONCAT(Recency, Frequency, Monetary) IN ('525', '524', '523', '522', '521', '515', '514', '513', '425', '424', '413', '414', '415', '315', '314', '313')  
        THEN 'Promising'  
    WHEN CONCAT(Recency, Frequency, Monetary) IN ('535', '534', '443', '434', '343', '334', '325', '324')  
        THEN 'Customers Needing Attention'  
    WHEN CONCAT(Recency, Frequency, Monetary) IN ('331', '321', '312', '221', '213')  
        THEN 'About To Sleep'  
    WHEN CONCAT(Recency, Frequency, Monetary) IN ('255', '254', '245', '244', '253', '252', '243', '242', '235', '234', '225', '224', '153', '152', '145', '143', '142', '135', '134', '133', '125', '124')  
        THEN 'At Risk'  
    WHEN CONCAT(Recency, Frequency, Monetary) IN ('155', '154', '144', '214', '215', '115', '114', '113')  
        THEN 'Can’t Lose Them'  
    WHEN CONCAT(Recency, Frequency, Monetary) IN ('332', '322', '231', '241', '251', '233', '232', '223', '222', '132', '123', '122', '212', '211')  
        THEN 'Hibernating'  
    WHEN CONCAT(Recency, Frequency, Monetary) IN ('111', '112', '121', '131', '141', '151')  
        THEN 'Lost'
END AS Reseller_Category into #FinalRFM
FROM #Monetary_Category m
JOIN #Frequency_Category f ON m.ResellerKey = f.ResellerKey
JOIN #Recency_Category r ON m.ResellerKey = r.ResellerKey

SELECT * FROM #FinalRFM
