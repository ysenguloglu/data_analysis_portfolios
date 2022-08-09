SELECT *
FROM Portfolio.dbo.Categories

SELECT *
FROM Portfolio.dbo.Customers

SELECT *
FROM Portfolio.dbo.Employees

SELECT *
FROM Portfolio.dbo.OrderDetails

SELECT *
FROM Portfolio.dbo.Orders

SELECT *
FROM Portfolio.dbo.Products

SELECT *
FROM Portfolio.dbo.Suppliers

--How many unique customers do we have?
SELECT COUNT(Distinct(CustomerID)) Num_of_Unique_Customer
FROM Portfolio.dbo.Orders

--How many customers do we have in each country?
SELECT COUNT(CustomerID) Num_of_Customers
, Country
FROM Portfolio.dbo.Customers
GROUP BY Country
ORDER BY 1 DESC

--How many customers do we have in each country and each city?
SELECT COUNT(CustomerID) Num_of_Customers
, Country
, City
FROM Portfolio.dbo.Customers
GROUP BY Country, City
ORDER BY 1 DESC

--How many products are sold in each category?
SELECT c.CategoryName
, COUNT(c.CategoryID) Num_of_Sales
FROM Portfolio.dbo.Products p
JOIN Portfolio.dbo.Categories c
ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY 2 DESC

--What is the average price of the categories?
SELECT c.CategoryName
, AVG(p.Price) Avg_Price
FROM Portfolio.dbo.Products p
JOIN Portfolio.dbo.Categories c
ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY 2 DESC

--Total sales by employees.
SELECT 
Name
, SUM(Price) as Total_Sales
FROM
(
SELECT Name = e.FirstName + ' ' + e.LastName
, p.Price  
FROM Portfolio.dbo.Employees e
JOIN Portfolio.dbo.Orders o
ON e.EmployeeID = o.EmployeeID
JOIN Portfolio.dbo.OrderDetails od
ON o.OrderID = od.OrderID
JOIN Portfolio.dbo.Products p
ON od.ProductID = p.ProductID
) S
GROUP BY Name
ORDER BY 2 DESC

--What is the average sales of countries by category?
SELECT 
c.Country
,ct.CategoryName
,Total_Sales = SUM(P.Price) 
FROM Portfolio.dbo.Customers c
JOIN Portfolio.dbo.Orders o
ON c.CustomerID = o.CustomerID
JOIN Portfolio.dbo.OrderDetails od
ON o.OrderID = od.OrderID
JOIN Portfolio.dbo.Products p
ON od.ProductID = p.ProductID
JOIN Portfolio.dbo.Categories ct
ON p.CategoryID = ct.CategoryID
GROUP BY c.Country
,ct.CategoryName
ORDER BY 1,3 Desc

--Top 3 sales of countries.
SELECT 
*
FROM
(
SELECT 
c.Country
,ct.CategoryName
,Total_Sales = SUM(P.Price)
,Rank = ROW_NUMBER() OVER(PARTITION BY c.Country ORDER BY SUM(P.Price) DESC)
FROM Portfolio.dbo.Customers c
JOIN Portfolio.dbo.Orders o
ON c.CustomerID = o.CustomerID
JOIN Portfolio.dbo.OrderDetails od
ON o.OrderID = od.OrderID
JOIN Portfolio.dbo.Products p
ON od.ProductID = p.ProductID
JOIN Portfolio.dbo.Categories ct
ON p.CategoryID = ct.CategoryID
GROUP BY c.Country
,ct.CategoryName
) A
WHERE Rank <= 3

--Employees who received orders with the order year 1997, sorted by the number of orders they received.
SELECT 
e.EmployeeID
, Num_of_Orders = COUNT(e.EmployeeID)
INTO #Employee_Sales
FROM Portfolio.dbo.Employees e
JOIN Portfolio.dbo.Orders o
ON e.EmployeeID = o.EmployeeID
WHERE o.OrderDate LIKE ('%.1997%')
GROUP BY e.EmployeeID

SELECT 
e.EmployeeID
, Name = e.FirstName + ' ' + e.LastName
, Num_of_Orders
FROM #Employee_Sales es
JOIN Portfolio.dbo.Employees e
ON es.EmployeeID = e.EmployeeID
ORDER BY 3 DESC

--Which employee has made how many sales from which category?

SELECT 
e.EmployeeID
, c.CategoryName
, Num_of_Orders = COUNT(c.CategoryName)
, Total_Sales_per_Category = SUM(p.Price)
FROM Portfolio.dbo.Employees e
JOIN Portfolio.dbo.Orders o
ON e.EmployeeID = o.EmployeeID
JOIN Portfolio.dbo.OrderDetails od
ON o.OrderID = od.OrderID
JOIN Portfolio.dbo.Products p
ON od.ProductID = p.ProductID
JOIN Portfolio.dbo.Categories c
ON p.CategoryID = c.CategoryID
GROUP BY e.EmployeeID, c.CategoryName
ORDER BY 1,4 DESC

--Customers by order quantity and total sales.
SELECT
c.CustomerName
, Num_of_Orders = COUNT(c.CustomerName) 
, Total_Sales = SUM(p.Price)
FROM Portfolio.dbo.Customers c
JOIN Portfolio.dbo.Orders o
ON c.CustomerID = o.CustomerID
JOIN Portfolio.dbo.OrderDetails od
ON o.OrderID = od.OrderID
JOIN Portfolio.dbo.Products p
ON od.ProductID = p.ProductID
GROUP BY c.CustomerName
ORDER BY 2 DESC

--The amount of orders placed by customers according to categories and the total amount of money they spend.
SELECT
*
, Total_Sales = SUM(Total_Sales_by_Category) OVER (PARTITION BY CustomerName)
FROM
(
SELECT
c.CustomerName
, ct.CategoryName
, Num_of_Orders = COUNT(c.CustomerName) 
, Total_Sales_by_Category = SUM(p.Price)
FROM Portfolio.dbo.Customers c
JOIN Portfolio.dbo.Orders o
ON c.CustomerID = o.CustomerID
JOIN Portfolio.dbo.OrderDetails od
ON o.OrderID = od.OrderID
JOIN Portfolio.dbo.Products p
ON od.ProductID = p.ProductID
JOIN Portfolio.dbo.Categories ct
ON p.CategoryID = ct.CategoryID
GROUP BY c.CustomerName, ct.CategoryName
) R
ORDER BY Total_Sales DESC

--Percentages of countries based on the number of orders placed.
SELECT 
c.Country
, Num_of_Countries = COUNT(c.Country)
, Total_Orders = SUM(COUNT(c.Country)) OVER ()
, Percentage = ((COUNT(c.Country))*1.0/SUM(COUNT(c.Country)) OVER ())*100
FROM Portfolio.dbo.Customers c
JOIN Portfolio.dbo.Orders o
ON c.CustomerID = o.CustomerID
JOIN Portfolio.dbo.OrderDetails od
ON o.OrderID = od.OrderID
JOIN Portfolio.dbo.Products p
ON od.ProductID = p.ProductID
GROUP BY c.Country
ORDER BY 4 DESC

--Now we'll visualize our inferences via Tableau.
