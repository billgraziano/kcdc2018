USE AdventureWorks2016
GO
IF OBJECT_ID('tempdb..#Orders') IS NOT NULL
	DROP TABLE #Orders
GO
CREATE TABLE #Orders (SalesOrderID INT)
DECLARE @Orders TABLE (SalesOrderID INT)

INSERT @Orders
SELECT TOP (1000) SalesOrderID
FROM	Sales.SalesOrderheader
ORDER BY NEWID()

INSERT #Orders
SELECT * FROM @Orders

SET STATISTICS IO ON
SELECT	H.*
FROM	Sales.SalesOrderHeader H
JOIN	@Orders O ON O.SalesOrderID = H.SalesOrderID

SELECT	H.*
FROM	Sales.SalesOrderHeader H
JOIN	#Orders O ON O.SalesOrderID = H.SalesOrderID
SET STATISTICS IO OFF


