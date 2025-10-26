/*======================================================================
Exploratory Data Analysis (EDA) on Supply Chain Database
========================================================================*/

USE SupplyChainDB;
GO

/*================================================
Step:1 Data Exploration
==================================================*/

SELECT COUNT(*) FROM Bronze.Stg_SupplyChainData;
SELECT COUNT(*) FROM Silver.Transform_SupplyChainData;

--Bronze Layer ---->To get the Get Table Schema, Column Name, Data Type, Max Length, Nullability and Total_Columns

SELECT 
	TABLE_SCHEMA,
	TABLE_NAME, 
	COLUMN_NAME, 
	DATA_TYPE,
	IS_NULLABLE,
COUNT(*) OVER () AS Total_Columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_SCHEMA = 'Bronze'
    AND TABLE_NAME = 'Stg_SupplyChainData';

--Silver Layer ---->To get the Get Table Schema, Column Name, Data Type, Max Length, Nullability and Total_Columns

SELECT 
	TABLE_SCHEMA,
	TABLE_NAME, 
	COLUMN_NAME, 
	DATA_TYPE,
	IS_NULLABLE,
COUNT(*) OVER () AS Total_Columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_SCHEMA = 'Silver'
    AND TABLE_NAME = 'Transform_SupplyChainData';


-- Retrieve all columns for a specific table (dim_customers)
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'VW_DimCustomers';


/*
=====================================================
Step:2 Dimensions Exploration
=====================================================*/

-- Explore Product Categories
SELECT * FROM Gold.VW_DimActualShipping;

-- Explore Stores
SELECT * FROM Gold.VW_DimStore;

-- Retrieve a list of unique countries from which customers originate
SELECT DISTINCT 
	CustomerId,
	CustomerFullName,
	CustomerCity
FROM Gold.VW_DimCustomers
ORDER BY CustomerCity;

-- Retrieve a list of unique ProductName, ProductCategoryId and ProductPrice

SELECT DISTINCT
	ProductName,
	ProductCategoryId,
	ProductPrice
FROM Gold.VW_DimProducts;

-- Retrieve a list of unique Types of Order Status 
SELECT DISTINCT * 
FROM Gold.VW_DimOrderStatus;


/*=======================================================
Step 3: Date Range Exploration 
=========================================================*/    

--Retrieve the Minimum Orders Date 
SELECT MIN(OrderDateDateOrders) AS Mini_Orders_Date
FROM Gold.VW_FactSales

--Retrieve the Maximum Orders Date 
SELECT MAX(OrderDateDateOrders) AS Max_Orders_Date
FROM Gold.VW_FactSales;

--Retrieve the Minimum Shipping Date 
SELECT MIN(ShippingDate) AS Mini_Shipping_Date
FROM Gold.VW_FactSales;

--Retrieve the Maximum Shipping Date 
SELECT MAX(ShippingDate) AS Max_Shipping_Date
FROM Gold.VW_FactSales;

-- Determine the first and last order date and the total duration in months

SELECT 
	MIN(OrderDateDateOrders) AS First_OrdersDate,
	MAX(OrderDateDateOrders) AS Last_OrdersDate,
	DATEDIFF (MONTH , MIN(OrderDateDateOrders), MAX(OrderDateDateOrders)) AS Orders_Range_Month
FROM Gold.VW_FactSales;

-- Determine the first and last Shipping date and the total duration in Years
SELECT 
	MIN(ShippingDate) AS First_Shipping_Date,
	MAX(ShippingDate) AS Last_Shipping_Date,
	DATEDIFF(YEAR, MIN(ShippingDate), MAX(ShippingDate)) AS Shipping_Range_Years
FROM Gold.VW_FactSales;

--Calculate the difference between scheduled shipping days and actual shipping days
SELECT 
	OrderId,
	ShipmentDaysScheduled,
	ShippingDaysReal,
	DATEDIFF(DAY, ShipmentDaysScheduled, ShippingDaysReal) AS Shipping_Delay_Days
FROM
Gold.VW_FactSales


/*======================================================
Step 4: Measures Exploration (Key Metrics)
========================================================*/

--Retrieve the total Orders, Min Orders, Max Orders , Min Revenue, Max revenue, Avg revenue and the total revenue  

SELECT
    COUNT(OrderId) AS Total_Orders,
    MIN(OrderId) AS Min_Orders,
    MAX(OrderId) AS Max_Orders,
	AVG(Sales) AS Avg_Revenue,
    SUM(Sales) AS Total_Revenue,
    MIN(Sales) AS Min_Revenue,
    MAX(Sales) AS Max_Revenue
FROM 
    Gold.VW_FactSales;


--Calculate the Unique and total Poducts Sold
SELECT 
	COUNT(DISTINCT(ProductKey)) AS Total_Unique_Products_Sold,
	SUM(OrderItemQuantity) AS Total_Products_Sold
FROM Gold.VW_FactSales;

--Calculate the total profit per orders
SELECT 
	SUM(OrderProfitPerOrder) AS Total_Profit_Per_Orders
FROM Gold.VW_FactSales

--Calculate the Unique and total Customers
SELECT 
	COUNT(CustomerId) AS Total_Customers,
	COUNT(DISTINCT(CustomerId)) AS Total_Unique_Customers
FROM Gold.VW_FactSales



/*=====================================================
Step 5: Magnitude Analysis
========================================================*/

--Calculate the total discount per Products and highest discounted products
SELECT 
 dp.ProductName,
 SUM(fs.DiscountRate) AS Total_Discount_Per_Products
FROM Gold.VW_FactSales AS fs
LEFT JOIN
Gold.VW_DimProducts AS dp
ON 
dp.Productkey = fs.ProductKey
GROUP BY ProductName
ORDER BY Total_Discount_Per_Products DESC;


-- Find total customers by highest countries
SELECT 
	CustomerCountry,
	COUNT(CustomerId) AS Total_Customers
FROM Gold.VW_DimCustomers
GROUP BY CustomerCountry
ORDER BY Total_Customers DESC;


--Find the highest Product Sold
SELECT 
  dp.ProductName,
  COUNT(*) AS Total_Products_Sold
FROM Gold.VW_DimProducts AS dp
LEFT JOIN Gold.VW_FactSales AS fs
  ON dp.ProductKey = fs.ProductKey 
GROUP BY dp.ProductName
ORDER BY Total_Products_Sold DESC;

-- Find total products by category
SELECT 
	dc.CategoryName,
	COUNT(fs.ProductKey) AS Total_Product_By_Category
FROM Gold.VW_FactSales AS fs
LEFT JOIN
Gold.VW_DimCategory AS dc
ON
fs.CategoryKey = dc.CategoryKey
GROUP BY CategoryName
ORDER BY Total_Product_By_Category DESC;


-- What is the highest average costs in each category?
SELECT 
	dc.CategoryName,
	CAST(AVG(fs.ProductPrice) AS INT) AS Avg_Price_Per_Category  -- Returns the average product price per category, rounded and cast as integer
FROM Gold.VW_FactSales AS fs
LEFT JOIN
Gold.VW_DimCategory AS dc 
ON
fs.CategoryKey = dc.CategoryKey
GROUP BY dc.CategoryName
ORDER BY Avg_Price_Per_Category DESC;


-- What is the total revenue generated for each category?

SELECT 
	dc.CategoryName,
	SUM(fs.Sales) AS Total_Sales_by_Category
FROM  Gold.VW_DimCategory AS dc
LEFT JOIN 
Gold.VW_FactSales AS fs
ON
dc.CategoryKey = fs.CategoryKey
GROUP BY dc.CategoryName
ORDER BY Total_Sales_by_Category DESC;

-- What is the total highest revenue generated by each customer?
SELECT 
	dc.CustomerFullName,
	SUM(fs.Sales) AS Total_Sales_by_Customer 
FROM  Gold.VW_DimCustomers AS dc
LEFT JOIN 
Gold.VW_FactSales AS fs
ON
dc.CustomerId = fs.CustomerId
GROUP BY dc.CustomerFullName
ORDER BY Total_Sales_by_Customer DESC;


-- What is the distribution of sold items across countries?
SELECT 
	dc.CustomerCountry,
	COALESCE(SUM(fs.OrderItemQuantity), 0) AS Total_Sold_Item_by_Country  --COALESCE to handle NULLs (from countries with no sales)
FROM Gold.VW_DimCustomers dc
LEFT JOIN Gold.VW_FactSales fs
ON
dc.CustomerId = fs.CustomerId 
GROUP BY dc.CustomerCountry
ORDER BY Total_Sold_Item_by_Country DESC;




/*==========================================================
Step 6: Ranking Analysis
==========================================================*/

-- Which 5 products Generating the Highest Revenue?
-- Simple Ranking
SELECT TOP 5
	dp.ProductName,
	SUM(Sales) AS Total_Highest_Revenue
FROM Gold.VW_DimProducts AS  dp
LEFT JOIN
Gold.VW_FactSales AS fs
ON
dp.ProductKey = fs.ProductKey
GROUP BY dp.ProductName
ORDER BY Total_Highest_Revenue DESC;


-- Complex but Flexibly Ranking Using Window Functions	
-- Which 5 products Generating the Highest Quantity?

SELECT * FROM 
	(SELECT
		dp.ProductName,
		SUM(fs.OrderItemQuantity) AS Total_Quantity,
		RANK() OVER(ORDER BY SUM(fs.OrderItemQuantity) DESC) AS Rank_Product_Quantity
		FROM Gold.VW_DimProducts AS  dp
		LEFT JOIN
		Gold.VW_FactSales AS fs
		ON
		dp.ProductKey = fs.ProductKey
		GROUP BY dp.ProductName
	) 
AS Ranked_Products
WHERE Rank_Product_Quantity <=5;


-- What are the 5 worst-performing products in terms of sales?

SELECT *
FROM
	(SELECT 
	dp.ProductName,
	SUM(fs.Sales) AS Total_Sales,
	SUM(fs.OrderItemQuantity) AS Total_Quantity,
	RANK() OVER (ORDER BY SUM(fs.Sales) ASC ) AS Rank_Worst_Performing_Products
	FROM Gold.VW_DimProducts AS  dp
	LEFT JOIN
	Gold.VW_FactSales AS fs
	ON
	dp.ProductKey = fs.ProductKey
	GROUP BY dp.ProductName) AS Ranked_Worst_Pro
WHERE Rank_Worst_Performing_Products <=5;

--Without Window Function
SELECT TOP 5
	dp.ProductName,
	SUM(fs.Sales) AS Total_Sales,
	SUM(fs.OrderItemQuantity) AS Total_Quantity
	FROM Gold.VW_DimProducts AS  dp
	LEFT JOIN
	Gold.VW_FactSales AS fs
	ON
	dp.ProductKey = fs.ProductKey
	GROUP BY dp.ProductName
	ORDER BY Total_Sales

-- Find the top 10 customers who have generated the highest revenue

SELECT *
FROM
	(SELECT 
		dc.CustomerFullName,
		SUM(fs.Sales) AS Total_Sales_by_Customer,
		RANK() OVER (ORDER BY SUM(fs.Sales) DESC) AS Rank_by_highest_Customer_Revenue
	FROM  Gold.VW_DimCustomers AS dc
	LEFT JOIN 
	Gold.VW_FactSales AS fs
	ON
	dc.CustomerId = fs.CustomerId
	GROUP BY dc.CustomerFullName) AS Ranked_Customer
WHERE Rank_by_highest_Customer_Revenue <=10;



-- The 3 customers with the fewest orders placed
SELECT TOP 3
    ds.CustomerId,
    ds.CustomerFullName,
    COUNT(fs.OrderID) AS Total_Orders
FROM Gold.VW_DimCustomers AS ds
LEFT JOIN Gold.VW_FactSales AS fs
    ON ds.CustomerId = fs.CustomerId
GROUP BY ds.CustomerId, ds.CustomerFullName
ORDER BY Total_Orders ASC;
