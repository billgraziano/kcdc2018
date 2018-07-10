---------------------------------------------------------------------------------------------
-- Writing Faster SQL
---------------------------------------------------------------------------------------------

-- FUNCTIONS IN THE WHERE CLAUSE
SET STATISTICS IO ON 
GO
SELECT	SalesOrderID
		,OrderDate
FROM	Sales.SalesOrderHeader
WHERE	YEAR(OrderDate) = 2012
AND		MONTH(OrderDate) = 7
GO

SELECT	SalesOrderID
		,OrderDate
FROM	Sales.SalesOrderHeader
WHERE	OrderDate >= '7/1/2012' 
AND		OrderDate < '8/1/2012'
GO


--------------------------------------------------------------------------------------------
-- Matching Data Types
--------------------------------------------------------------------------------------------

SET STATISTICS IO ON
GO
  SELECT *
  FROM	Sales.Customer
  WHERE AccountNumber = N'AW00000557'

 SELECT *
  FROM	Sales.Customer
  WHERE AccountNumber = 'AW00000557'

--------------------------------------------------------------------------------------------
-- INCLUDE
--------------------------------------------------------------------------------------------
SELECT  	SUM(D.LineTotal) AS LineTotal
FROM		Sales.SalesOrderHeader H
JOIN		Sales.SalesOrderDetail D 
	ON D.SalesOrderID = H.SalesOrderID
WHERE	H.CustomerID = 25924
AND		H.[Status] = 5

CREATE NONCLUSTERED INDEX [IX_Sales_Customer_INCLDUE] ON [Sales].[SalesOrderHeader]
( [CustomerID] ASC )  INCLUDE ( [Status] ) 


DROP INDEX [IX_Sales_Customer_INCLDUE] ON [Sales].[SalesOrderHeader]

--------------------------------------------------------------------------------------------
-- FILTER
--------------------------------------------------------------------------------------------

SELECT	SalesOrderID, CustomerID, OrderDate
FROM	Sales.SalesOrderHeader 
WHERE	CustomerID = 29824
AND		ShipMethodID = 5
ORDER BY OrderDate


CREATE NONCLUSTERED INDEX [IX_SalesOrderHeader_FILTERED] ON [Sales].[SalesOrderHeader]
(	[CustomerID] ASC,
	[OrderDate] ASC  )
WHERE ShipMethodID = 5

DROP INDEX  [IX_SalesOrderHeader_FILTERED] ON [Sales].[SalesOrderHeader]


--------------------------------------------------------------------------------------------
-- Use EXISTS
--------------------------------------------------------------------------------------------
Use AdventureWorks;
GO
DECLARE @Rows INT;

SELECT @Rows = COUNT(*)
FROM	Sales.SalesOrderHeader
WHERE	Status = 5;

IF @Rows > 0 PRINT 'Found!';
GO

IF EXISTS (SELECT 1 FROM Sales.SalesOrderHeader WHERE	Status = 5)
	PRINT 'Found!';
GO

-- IN clause
SELECT *
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (25924, 11147, 14720, 28407, 20170)



