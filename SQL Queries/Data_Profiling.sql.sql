/* ===============================================================================================
   Purpose here is:- To check size, data types, missing values, duplicates and odd values in dataset
   ===============================================================================================*/
USE PRACTICE_GP;   
GO

-- Q1): How big is each table?
SELECT 'sales' AS TableName, COUNT(*) AS TotalRows FROM sales
UNION ALL SELECT 'products',   COUNT(*) FROM products
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'customers',  COUNT(*) FROM customers
UNION ALL SELECT 'employees',  COUNT(*) FROM employees
UNION ALL SELECT 'cities',     COUNT(*) FROM cities
UNION ALL SELECT 'countries',  COUNT(*) FROM countries;
/* [FINDINGs:- TotalRows of each Found:- 
    sales:	   6758125
    products:  452
    categories:11
    customers: 98759
    employees: 23
    cities:	   96
    countries: 206]
*/

-- Q2): main overview of data and what data type is of each column??
SELECT TOP 10 * FROM sales;
SELECT TOP 10 * FROM products;

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('sales','products','customers','employees','cities','countries','categories')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
--[FINDINGs: SalesDate and HireDate is stored as "datetime2" which is not useful here while ModifyDate is correctly stored as "date"]



-- Q3): Are there any null values??
SELECT COUNT(*) AS TotalRows,
  SUM(CASE WHEN SalesPersonID      IS NULL THEN 1 ELSE 0 END) AS Null_SalesPersonID,
  SUM(CASE WHEN CustomerID         IS NULL THEN 1 ELSE 0 END) AS Null_CustomerID,
  SUM(CASE WHEN ProductID          IS NULL THEN 1 ELSE 0 END) AS Null_ProductID,
  SUM(CASE WHEN Quantity           IS NULL THEN 1 ELSE 0 END) AS Null_Quantity,
  SUM(CASE WHEN Discount           IS NULL THEN 1 ELSE 0 END) AS Null_Discount,
  SUM(CASE WHEN TotalPrice         IS NULL THEN 1 ELSE 0 END) AS Null_TotalPrice,
  SUM(CASE WHEN SalesDate          IS NULL THEN 1 ELSE 0 END) AS Null_SalesDate,
  SUM(CASE WHEN TransactionNumber  IS NULL THEN 1 ELSE 0 END) AS Null_TransactionNumber,
  SUM(CASE WHEN Revenue            IS NULL THEN 1 ELSE 0 END) AS Null_Revenue
FROM sales;
-- [FINDINGs: Only SalesDate col have NULLs which are (67526) ]


-- Q4): Are there any duplicates??
-- 4a: the same SalesID appearing more than once
SELECT SalesID, 
    COUNT(*) AS Times 
FROM sales 
GROUP BY SalesID HAVING COUNT(*) > 1;
--[FINDINGs:No rows returned]

-- 4b: the same sale line repeated with a different SalesID
SELECT TransactionNumber, ProductID, CustomerID, SalesPersonID, Quantity, SalesDate, COUNT(*) AS Times
FROM sales
GROUP BY TransactionNumber, ProductID, CustomerID, SalesPersonID, Quantity, SalesDate
HAVING COUNT(*) > 1;
--[FINDINGs:No rows returned]

-- 4c: products with the same name
SELECT ProductName, COUNT(*) AS Times FROM products GROUP BY ProductName HAVING COUNT(*) > 1;
-- FINDINGs: No rows returned, hence no duplicates exist. 

-- Q5): checking if any Broken links ?
SELECT
 (SELECT COUNT(*) FROM dbo.sales s LEFT JOIN dbo.customers c ON s.CustomerID = c.CustomerID
   WHERE s.CustomerID IS NOT NULL AND c.CustomerID IS NULL)    AS missing_customers,
 (SELECT COUNT(*) FROM dbo.sales s LEFT JOIN dbo.products p ON s.ProductID = p.ProductID
   WHERE s.ProductID IS NOT NULL AND p.ProductID IS NULL)      AS missing_products,
 (SELECT COUNT(*) FROM dbo.sales s LEFT JOIN dbo.employees e ON s.SalesPersonID = e.EmployeeID
   WHERE s.SalesPersonID IS NOT NULL AND e.EmployeeID IS NULL) AS missing_salespeople;
-- RESULT: (write what you saw)


--Q6): Are the labels and dates consistent??
SELECT IsAllergic, COUNT(*) AS TotalRows FROM products GROUP BY IsAllergic ORDER BY TotalRows DESC;
SELECT Class,      COUNT(*) AS TotalRows FROM products GROUP BY Class      ORDER BY TotalRows DESC;
SELECT Resistant,  COUNT(*) AS TotalRows FROM products GROUP BY Resistant  ORDER BY TotalRows DESC;

SELECT MIN(TRY_CONVERT(DATE, SalesDate)) AS FirstSale,
       MAX(TRY_CONVERT(DATE, SalesDate)) AS LastSale
FROM sales;


-- Dates that cannot be read as real dates
SELECT TOP 20 SalesID, SalesDate
FROM sales
WHERE SalesDate IS NOT NULL AND TRY_CONVERT(DATE, SalesDate) IS NULL;
-- [FINDING :blank rows]

--Q7): checking if any impossible values?  
SELECT MIN(Quantity) AS MinQty, MAX(Quantity) AS MaxQty,
       MIN(Discount) AS MinDiscount, MAX(Discount) AS MaxDiscount,
       MIN(Revenue)  AS MinRevenue,  MAX(Revenue)  AS MaxRevenue
FROM sales;

SELECT COUNT(*) AS BadRows
FROM sales
WHERE Quantity <= 0 OR Discount < 0 OR Revenue < 0;
