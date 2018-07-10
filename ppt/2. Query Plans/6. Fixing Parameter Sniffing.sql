use AdventureWorks2016
GO
SET STATISTICS IO ON
---------------------------------------------------------------------------------------------------------
-- Using WITH RECOMPILE at Execution time
---------------------------------------------------------------------------------------------------------
SET STATISTICS IO ON;

DBCC FREEPROCCACHE
GO
EXEC ParameterSniffing 'KS' WITH RECOMPILE
GO
EXEC ParameterSniffing 'MO' WITH RECOMPILE  -- no plan saved
GO
select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO

---------------------------------------------------------------------------------------------------------
-- Using WITH RECOMPILE at Compile Time
---------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ParameterSniffingRecompile]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[ParameterSniffingRecompile]
GO
CREATE PROC	ParameterSniffingRecompile
	( @RegionCode CHAR(2) ) 
        WITH RECOMPILE -- This is different
AS
SELECT	*
FROM	Sales.SalesOrderHeader
WHERE	RegionCode = @RegionCode 
GO


DBCC FREEPROCCACHE
GO
EXEC ParameterSniffingRecompile 'KS'
GO
EXEC ParameterSniffingRecompile 'MO'
GO
select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO



---------------------------------------------------------------------------------------------------------
-- Using OPTION (RECOMPILE)
---------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ParameterSniffingRecompile]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[ParameterSniffingRecompile]
GO
CREATE PROC	ParameterSniffingRecompile
	@RegionCode CHAR(2)  ----- Recompile is gone from here
AS
SELECT	*
FROM	Sales.SalesOrderHeader
WHERE	RegionCode = @RegionCode 
OPTION(RECOMPILE);  ----- Recompile is added here
GO


DBCC FREEPROCCACHE
GO
EXEC ParameterSniffingRecompile 'KS'
GO
EXEC ParameterSniffingRecompile 'MO'
GO
select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO


---------------------------------------------------------------------------------------------------------
-- Using OPTION ( OPTIMIZE FOR() )
---------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ParameterSniffingOptimizedFor]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[ParameterSniffingOptimizedFor]
GO
CREATE PROC	[ParameterSniffingOptimizedFor]
	@RegionCode CHAR(2)  
AS
SELECT	*
FROM	Sales.SalesOrderHeader
WHERE	RegionCode = @RegionCode 
OPTION(OPTIMIZE FOR (@RegionCode = 'MO'))  ----- This is different
GO

DBCC FREEPROCCACHE
GO
EXEC [ParameterSniffingOptimizedFor] 'KS'
GO
EXEC [ParameterSniffingOptimizedFor] 'MO'
GO
select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO



---------------------------------------------------------------------------------------------------------
-- Replace Parameters with Local Variable
---------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ParameterSniffingLocalVariable]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[ParameterSniffingLocalVariable]
GO
CREATE PROC	[ParameterSniffingLocalVariable]
	@RegionCode CHAR(2)
AS
DECLARE @LocalRegionCode CHAR(2)
SELECT	@LocalRegionCode = @RegionCode

SELECT	*
FROM	Sales.SalesOrderHeader
WHERE	RegionCode = @LocalRegionCode 
GO

DBCC FREEPROCCACHE
GO
EXEC [ParameterSniffingLocalVariable] 'KS'
GO
EXEC [ParameterSniffingLocalVariable] 'MO'
GO

select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO



---------------------------------------------------------------------------------------------------------
-- Resetting a parameter -- often used to adjust date ranges or set defaults
---------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ParameterSniffingRewrite]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[ParameterSniffingRewrite]
GO
CREATE PROC	[ParameterSniffingRewrite]
	@RegionCode CHAR(2)
AS
SELECT	@RegionCode = 'MO'

SELECT	*
FROM	Sales.SalesOrderHeader
WHERE	RegionCode = @RegionCode 
GO

DBCC FREEPROCCACHE
GO
EXEC [ParameterSniffingRewrite] 'KS'
GO

select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO
