-----------------------------------------------------------------------------------------------------------------
-- Setup  & Start Profiler & Display Actual Execution Plan
-----------------------------------------------------------------------------------------------------------------
--ALTER DATABASE [AdventureWorks2016] SET PARAMETERIZATION	SIMPLE
ALTER DATABASE [AdventureWorks2016] SET PARAMETERIZATION	FORCED 
GO

use AdventureWorks2016
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ParameterSniffing]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[ParameterSniffing]


IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Sales].[SalesOrderHeader]') AND name = N'IX_SalesOrderHeader_RegionCode')
	DROP INDEX [IX_SalesOrderHeader_RegionCode] ON [Sales].[SalesOrderHeader] WITH ( ONLINE = OFF )

IF  EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'RegionCode' AND TABLE_NAME = 'SalesOrderHeader')
	ALTER TABLE Sales.SalesOrderHeader DROP COLUMN  RegionCode
GO



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'RegionCode' AND TABLE_NAME = 'SalesOrderHeader')
	ALTER TABLE Sales.SalesOrderHeader
	  ADD RegionCode CHAR(2) NULL
GO
UPDATE Sales.SalesOrderHeader
SET		RegionCode = 'MO'

UPDATE Sales.SalesOrderHeader
SET		RegionCode = 'KS'
WHERE	SalesOrderID IN (SELECT TOP 5 SalesOrderID 
							FROM Sales.SalesOrderHeader 
							ORDER BY NEWID() )

CREATE INDEX IX_SalesOrderHeader_RegionCode ON Sales.SalesOrderHeader(RegionCode)
GO

---------------------------------------------------------------------------------------------------------
-- Start Profiler & How many query plans?
---------------------------------------------------------------------------------------------------------
SET STATISTICS IO ON
GO
DBCC FREEPROCCACHE
GO
SELECT	*
FROM	Sales.SalesOrderHeader
WHERE	RegionCode = 'MO'
GO
			--DBCC FREEPROCCACHE
			--GO
SELECT	*
FROM	Sales.SalesOrderHeader
WHERE	RegionCode = 'KS'
GO

select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO

-------------------------- Add another predicate -----------------------------------------------
DBCC FREEPROCCACHE
GO
SELECT	*
FROM	Sales.SalesOrderHeader
WHERE	RegionCode = 'MO' AND SalesOrderID = 22000
GO

SELECT	*
FROM	Sales.SalesOrderHeader
WHERE	RegionCode = 'KS' AND SalesOrderID = 22001
GO

select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO



---------------------------------------------------------------------------------------------------------
-- Demo stored procedure parameterization
---------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ParameterSniffing]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[ParameterSniffing]

GO
CREATE PROC	ParameterSniffing
	@RegionCode CHAR(2)
AS
SELECT	*
FROM	Sales.SalesOrderHeader
WHERE	RegionCode = @RegionCode
GO

-- Both Run Clean ----------------------------------------------
-- Show Query Plan
SET STATISTICS IO ON 
DBCC FREEPROCCACHE
EXEC ParameterSniffing 'KS'
GO

DBCC FREEPROCCACHE
EXEC ParameterSniffing 'MO'
GO


-- 'MO' then 'KS' -----------------------------------------------------
-- INclude the actual query plan
DBCC FREEPROCCACHE
GO
EXEC ParameterSniffing 'MO'
GO
EXEC ParameterSniffing 'KS' 
GO



select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO

-- 'KS' then 'MO' ----------------------------------------------------
-- Index Usage
DBCC FREEPROCCACHE
GO
EXEC ParameterSniffing 'KS'
GO
EXEC ParameterSniffing 'MO'
GO



select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO
