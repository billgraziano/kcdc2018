-- Use Window function in a WHERE clause
;WITH CTE1 AS (
	SELECT *
			, ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS OrderDateRank
			, ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY SubTotal) AS OrderSizeRank
	FROM Sales.SalesOrderHeader
)
SELECT	CustomerID
		,SalesOrderNumber
		,OrderDate
		,OrderDateRank
		,SubTotal
		,OrderSizeRank
		--,*
FROM	CTE1
WHERE	OrderDateRank = 1
OR		OrderSizeRank = 1 
ORDER BY CTE1.CustomerID, CTE1.OrderDateRank, CTE1.OrderSizeRank


-- LAG Function
SELECT CustomerID, OrderDate
		,ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS OrderSeq
		,LAG(OrderDate, 1, NULL) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS PreviousDate
FROM	Sales.SalesOrderHeader H
ORDER BY H.CustomerID, H.OrderDate