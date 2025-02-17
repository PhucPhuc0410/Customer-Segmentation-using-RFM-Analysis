import pandas as pd
import pyodbc
from datetime import datetime

import matplotlib.pyplot as plt
import squarify

# Import data
conn = pyodbc.connect('DRIVER={SQL Server};'
                      'SERVER=your_local_host;'
                      'DATABASE=AdventureWorksDW2022;'
                      'Trusted_Connection=yes;')

df_FactResellerSales = pd.read_sql("SELECT ResellerKey, SalesAmount, SalesOrderNumber, OrderDate FROM FactResellerSales", conn)

# Recency Calculation
current_date = datetime(2013, 11, 29)
df_recency = df_FactResellerSales.groupby('ResellerKey')['OrderDate'].max().reset_index()
df_recency['GapDay'] = (current_date - df_recency['OrderDate']).dt.days
df_recency['Recency'] = pd.cut(df_recency['GapDay'], 5, labels=[5, 4, 3, 2, 1], duplicates='drop')

# Frequency Calculation
df_frequency = df_FactResellerSales.groupby('ResellerKey')['SalesOrderNumber'].nunique().reset_index()
df_frequency['Frequency'] = pd.cut(df_frequency['SalesOrderNumber'], 5, labels=[1, 2, 3, 4, 5], duplicates='drop')

# Monetary Calculation
df_monetary = df_FactResellerSales.groupby('ResellerKey')['SalesAmount'].sum().reset_index()
df_monetary['Monetary'] = pd.cut(df_monetary['SalesAmount'], 5, labels=[1, 2, 3, 4, 5], duplicates='drop')

# Merge table
df_rfm = df_recency[['ResellerKey', 'GapDay', 'Recency']]
df_rfm = df_rfm.merge(df_frequency[['ResellerKey', 'SalesOrderNumber', 'Frequency']], on='ResellerKey')
df_rfm = df_rfm.merge(df_monetary[['ResellerKey', 'SalesAmount', 'Monetary']], on='ResellerKey')

df_rfm['RFM'] = df_rfm['Recency'].astype(str) + df_rfm['Frequency'].astype(str) + df_rfm['Monetary'].astype(str)

# Final RFM segmentation
category_mapping = {
    ('555', '554', '545', '544', '455', '445', '454'): 'Champions',
    ('543', '444', '435', '355', '354', '345', '344', '335'): 'Loyal Customers',
    ('553', '551', '552', '541', '542', '533', '532', '531', '452', '451', '442', '441', '431', '453', '433', '432', '423', '353', '352', '351', '342', '341', '333', '323'): 'Potential Loyalist',
    ('512', '511', '422', '421', '412', '411', '311'): 'Recent Customers',
    ('525', '524', '523', '522', '521', '515', '514', '513', '425', '424', '413', '414', '415', '315', '314', '313'): 'Promising',
    ('535', '534', '443', '434', '343', '334', '325', '324'): 'Customers Needing Attention',
    ('331', '321', '312', '221', '213'): 'About To Sleep',
    ('255', '254', '245', '244', '253', '252', '243', '242', '235', '234', '225', '224', '153', '152', '145', '143', '142', '135', '134', '133', '125', '124'): 'At Risk',
    ('155', '154', '144', '214', '215', '115', '114', '113'): 'Can’t Lose Them',
    ('332', '322', '231', '241', '251', '233', '232', '223', '222', '132', '123', '122', '212', '211'): 'Hibernating',
    ('111', '112', '121', '131', '141', '151'): 'Lost'
}

df_rfm['Reseller_Category'] = df_rfm['RFM'].apply(lambda x: next((v for k, v in category_mapping.items() if x in k), 'Unknown'))

print(df_rfm)

# Treemap

df_rfm['Recency'] = df_rfm['Recency'].astype(int)

df_rfm_counts = df_rfm.groupby('Reseller_Category').agg(
    Count=('ResellerKey', 'count'),
    Avg_Recency=('Recency', 'mean')
).reset_index()

plt.figure(figsize=(10, 6))
squarify.plot(
    sizes=df_rfm_counts['Count'],
    label=df_rfm_counts['Reseller_Category'],
    alpha=0.7
)

plt.title('Reseller Segmentation using RFM')
plt.axis('off')
plt.show()


