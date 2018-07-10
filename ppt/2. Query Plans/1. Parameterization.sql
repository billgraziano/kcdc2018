use AdventureWorks2016
GO
/*
ALTER DATABASE [AdventureWorks2016] SET PARAMETERIZATION FORCED 
GO
ALTER DATABASE [AdventureWorks2016] SET PARAMETERIZATION SIMPLE 
GO
*/
select [name], is_parameterization_forced from master.sys.databases order by 1 

---------------------------------- Single Statement --------------------------------------------
DBCC FREEPROCCACHE
SET STATISTICS IO ON;
GO

select *
from	Sales.SalesOrderHeader
WHERE	SalesOrderID = 56000
AND		RevisionNumber = 8
GO

select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO

---------------------------------- Multiple Statements --------------------------------------------
DBCC FREEPROCCACHE
GO

SELECT	*
FROM	Sales.SalesOrderHeader
WHERE	SalesOrderID = 56000
GO

SELECT	* FROM	Sales.SalesOrderHeader WHERE	SalesOrderID = 56001
GO

select	*
from	Sales.SalesOrderHeader
where	SalesOrderID = 56002
GO

declare @i int
set @i = 56004
SELECT *
FROM Sales.SalesOrderHeader
WHERE SalesOrderID = @i
GO

select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO


---------------------------------- Complex Parameterization --------------------------------------------
DBCC FREEPROCCACHE
GO

SELECT  SUM(LineTotal) AS LineTotal
FROM	Sales.SalesOrderHeader H
JOIN	Sales.SalesOrderDetail D ON D.SalesOrderID = H.SalesOrderID
WHERE	H.SalesOrderID = 56000
GO

SELECT  SUM(LineTotal) AS LineTotal
FROM	Sales.SalesOrderHeader H
JOIN	Sales.SalesOrderDetail D ON D.SalesOrderID = H.SalesOrderID
WHERE	H.SalesOrderID = 56001
GO



select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO


-------------------------------------------------------------------------------------------
-- Next Slide
-------------------------------------------------------------------------------------------



---------------------------------- Explicit Parameterization in the query--------------------------------------------
-- Demo text changes

DBCC FREEPROCCACHE
GO

EXEC sp_executesql N'SELECT  SUM(LineTotal) AS LineTotal
FROM	Sales.SalesOrderHeader H
JOIN Sales.SalesOrderDetail D ON D.SalesOrderID = H.SalesOrderID
WHERE	H.SalesOrderID = @SalesOrderID', N'@SalesOrderID INT', 56000
GO

EXEC sp_executesql N'SELECT  SUM(LineTotal) AS LineTotal
FROM	Sales.SalesOrderHeader H
JOIN Sales.SalesOrderDetail D ON D.SalesOrderID = H.SalesOrderID
WHERE	H.SalesOrderID = @SalesOrderID', N'@SalesOrderID INT', 56005
GO

select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO


/* FORCED Slide */

ALTER DATABASE [AdventureWorks2016] SET PARAMETERIZATION SIMPLE 
GO
