USE [AdventureworksDW2016_EXT]
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
go


DBCC DROPCLEANBUFFERS



SELECT s.SalesTerritoryRegion,d.[CalendarYear],FirstName + ' ' + lastName as 'Employee',FORMAT(SUM(f.SalesAmount),'C') AS 'Total Sales', 
SUM(f.OrderQuantity) as 'Order Quantity', COUNT(distinct f.SalesOrdernumber) as 'Number of Orders', 
count(distinct f.Resellerkey) as 'Num of Resellers'
FROM FactResellerSalesXL_PageCompressed f
INNER JOIN [dbo].[DimDate] d ON f.OrderDateKey= d.Datekey
INNER JOIN [dbo].[DimSalesTerritory] s on s.SalesTerritoryKey=f.SalesTerritoryKey
INNER JOIN [dbo].[DimEmployee] e on e.EmployeeKey=f.EmployeeKey
WHERE FullDateAlternateKey between '1/1/2005' and '1/1/2007'
GROUP BY d.[CalendarYear],s.SalesTerritoryRegion,FirstName + ' ' + lastName
ORDER BY SalesTerritoryRegion,CalendarYear,[Total Sales] desc

DBCC DROPCLEANBUFFERS

SELECT s.SalesTerritoryRegion,d.[CalendarYear],FirstName + ' ' + lastName as 'Employee',FORMAT(SUM(f.SalesAmount),'C') AS 'Total Sales', 
SUM(f.OrderQuantity) as 'Order Quantity', COUNT(distinct f.SalesOrdernumber) as 'Number of Orders', 
count(distinct f.Resellerkey) as 'Num of Resellers'
FROM FactResellerSalesXL_CCI  f
INNER JOIN [dbo].[DimDate] d ON f.OrderDateKey= d.Datekey
INNER JOIN [dbo].[DimSalesTerritory] s on s.SalesTerritoryKey=f.SalesTerritoryKey
INNER JOIN [dbo].[DimEmployee] e on e.EmployeeKey=f.EmployeeKey
WHERE FullDateAlternateKey between '1/1/2005' and '1/1/2007'
GROUP BY d.[CalendarYear],s.SalesTerritoryRegion,FirstName + ' ' + lastName
ORDER BY SalesTerritoryRegion,CalendarYear,[Total Sales] desc

------------------------------
-- Index sizes
--------------------------------

SELECT OBJECT_SCHEMA_NAME(i.OBJECT_ID) SchemaName,
OBJECT_NAME(i.OBJECT_ID ) TableName,
i.name IndexName,
SUM(s.used_page_count) / 128.0 IndexSizeinMB
FROM sys.indexes AS i
INNER JOIN sys.dm_db_partition_stats AS S
ON i.OBJECT_ID = S.OBJECT_ID AND I.index_id = S.index_id
WHERE  i.type_desc like '%columnstore%'
GROUP BY i.OBJECT_ID, i.name

SELECT     OBJECT_NAME(rg.object_id)   AS TableName,
i.name                      AS IndexName,
i.type_desc                 AS IndexType,
rg.partition_number,
rg.row_group_id,
rg.total_rows,
rg.size_in_bytes,
rg.deleted_rows,
rg.[state],
rg.state_description
, size_in_bytes / total_rows as bytes_per_row
FROM       sys.column_store_row_groups AS rg
INNER JOIN sys.indexes                 AS i
ON   i.object_id                  = rg.object_id
AND  i.index_id                   = rg.index_id
--WHERE      i.name = N'CCX_LoginEvent'
ORDER BY   TableName, IndexName,
rg.partition_number, rg.row_group_id;
