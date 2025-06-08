
CREATE DATABASE IF NOT EXISTS EcommerceAnalysis;
USE EcommerceAnalysis;


CREATE TABLE Amazon_Sales (
    Order_ID VARCHAR(50),
    Date DATE,
    Status VARCHAR(50),
    Fulfillment VARCHAR(50),
    Sales_Channel VARCHAR(50),
    Category VARCHAR(100),
    Size VARCHAR(20),
    Style VARCHAR(50),
    SKU VARCHAR(50),
    ASIN VARCHAR(50),
    Qty INT,
    Currency VARCHAR(10),
    Gross_Amt DECIMAL(10,2)
);

CREATE TABLE International_Sales (
    Order_ID VARCHAR(50),
    Country VARCHAR(50),
    Shipping_Method VARCHAR(50),
    Date DATE,
    Sales_Amount DECIMAL(10,2),
    Currency VARCHAR(10)
);

CREATE TABLE Sale_Report (
    Order_ID VARCHAR(50),
    Product_Name VARCHAR(100),
    Brand VARCHAR(50),
    Quantity INT,
    Price DECIMAL(10,2),
    Discount DECIMAL(10,2),
    Final_Amount DECIMAL(10,2)
);

CREATE TABLE Profit_Loss_March (
    Order_ID VARCHAR(50),
    Revenue DECIMAL(10,2),
    Cost DECIMAL(10,2),
    Profit DECIMAL(10,2)
);

CREATE TABLE May_Sales (
    Order_ID VARCHAR(50),
    Product_Name VARCHAR(100),
    Sales_Channel VARCHAR(50),
    Qty INT,
    Unit_Price DECIMAL(10,2),
    Total_Amount DECIMAL(10,2)
);

CREATE TABLE Expense_IIGF (
    Expense_ID INT,
    Order_ID VARCHAR(50),
    Expense_Type VARCHAR(50),
    Expense_Amount DECIMAL(10,2),
    Vendor_Name VARCHAR(50)
);

CREATE TABLE Warehouse_Comparison (
    SKU VARCHAR(50),
    Product_Name VARCHAR(100),
    In_Stock INT,
    Warehouse_Location VARCHAR(50),
    Warehouse_Type VARCHAR(50)
);

-- Total gross sales per category
SELECT Category, SUM(Gross_Amt) AS Total_Revenue
FROM Amazon_Sales
GROUP BY Category
ORDER BY Total_Revenue DESC;

-- Profit per order
SELECT Order_ID, Revenue, Cost, Profit
FROM Profit_Loss_March
ORDER BY Profit DESC;

-- Revenue minus expense
SELECT A.Order_ID, SUM(A.Gross_Amt) AS Revenue, SUM(E.Expense_Amount) AS Total_Expense,
       (SUM(A.Gross_Amt) - SUM(E.Expense_Amount)) AS Net_Profit
FROM Amazon_Sales A
JOIN Expense_IIGF E ON A.Order_ID = E.Order_ID
GROUP BY A.Order_ID;

-- Average sale per channel
SELECT Sales_Channel, AVG(Total_Amount) AS Avg_Sale
FROM May_Sales
GROUP BY Sales_Channel;

-- Top 5 highest expenses
SELECT Order_ID, SUM(Expense_Amount) AS Total_Expense
FROM Expense_IIGF
GROUP BY Order_ID
ORDER BY Total_Expense DESC
LIMIT 5;

-- International revenue by country
SELECT Country, SUM(Sales_Amount) AS Revenue
FROM International_Sales
GROUP BY Country
ORDER BY Revenue DESC;

-- Products low in stock
SELECT Product_Name, In_Stock, Warehouse_Location
FROM Warehouse_Comparison
WHERE In_Stock < 50;

-- Orders above average revenue
SELECT *
FROM Amazon_Sales
WHERE Gross_Amt > (SELECT AVG(Gross_Amt) FROM Amazon_Sales);

-- Full order info via join
SELECT A.Order_ID, A.Category, S.Product_Name, S.Brand, S.Final_Amount
FROM Amazon_Sales A
JOIN Sale_Report S ON A.Order_ID = S.Order_ID;

-- Indexing for performance
CREATE INDEX idx_order ON Amazon_Sales(Order_ID);

CREATE INDEX idx_expense_order ON Expense_IIGF(Order_ID);

-- Find NULLs
SELECT *
FROM Amazon_Sales
WHERE SKU IS NULL;

-- Monthly revenue summary
SELECT MONTH(Date) AS Sale_Month, SUM(Gross_Amt) AS Monthly_Revenue
FROM Amazon_Sales
GROUP BY MONTH(Date)
ORDER BY Sale_Month;

-- Common order IDs between domestic and international
SELECT DISTINCT A.Order_ID
FROM Amazon_Sales A
JOIN International_Sales I ON A.Order_ID = I.Order_ID;

-- Monthly summary of revenue vs cost
SELECT MONTH(A.Date) AS Month, SUM(A.Gross_Amt) AS Total_Revenue, SUM(P.Cost) AS Total_Cost
FROM Amazon_Sales A
JOIN Profit_Loss_March P ON A.Order_ID = P.Order_ID
GROUP BY MONTH(A.Date);
