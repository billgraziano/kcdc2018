use AdventureWorks2016
GO
SET STATISTICS IO ON ;

-- SETUP -----------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Sales].[SalesOrderHeader]') AND name = N'IX_SalesOrderHeader_SalesPersonID')
    DROP INDEX [IX_SalesOrderHeader_SalesPersonID] ON [Sales].[SalesOrderHeader] WITH ( ONLINE = OFF )
GO
CREATE NONCLUSTERED INDEX [IX_SalesOrderHeader_SalesPersonID] ON [Sales].[SalesOrderHeader] 
    (	[SalesPersonID] ASC )  INCLUDE ( [TotalDue]) 
GO
---------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Report_Static]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[Report_Static]
GO
CREATE PROCEDURE dbo.Report_Static (
    @CustomerID INT = NULL,
    @SalesPersonID INT = NULL )
AS
  BEGIN
    SELECT  COUNT(*) AS Orders,
            SUM(TotalDue) as TotalDue
    FROM    Sales.SalesOrderHeader SOH
    WHERE   (CustomerID = @CustomerID OR @CustomerID IS NULL)
    AND     SalesPersonID = COALESCE(@SalesPersonID, SalesPersonID)
  END
GO


------------------------------------------------------------------------------------------
 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Report_Dynamic]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].Report_Dynamic
GO
CREATE PROCEDURE dbo.Report_Dynamic (
    @CustomerID INT = NULL,
    @SalesPersonID INT = NULL )
AS
  BEGIN

    DECLARE @sql NVARCHAR(MAX);

    SELECT @sql = '    SELECT  COUNT(*) AS Orders,
            SUM(TotalDue) as TotalDue
    FROM    Sales.SalesOrderHeader SOH
    WHERE   1=1 '

    IF @CustomerID IS NOT NULL
        SET @sql = @sql + ' AND CustomerID = @CustID '
    
    IF @SalesPersonID IS NOT NULL
        SET @sql = @sql + ' AND SalesPersonID = @SalesID '
    

    EXEC sp_executesql 
        @sql,
        N'@CustID INT, @SalesID INT',
        @CustID = @CustomerID,
        @SalesID = @SalesPersonID
        
  END
GO

---------------------------------------------------------------------------------------------------
SET STATISTICS IO ON 

EXEC dbo.Report_Static @CustomerID = 29717
GO
EXEC dbo.Report_Dynamic @CustomerID = 29717
GO

EXEC dbo.Report_Static @SalesPersonID = 283
GO
EXEC dbo.Report_Dynamic @SalesPersonID = 283
GO

EXEC dbo.Report_Static @CustomerID = 29717, @SalesPersonID = 283
GO
EXEC dbo.Report_Dynamic @CustomerID = 29717, @SalesPersonID = 283
GO

-- And what's stored in cache? ---------------------------------------------------------
DBCC FREEPROCCACHE
GO
EXEC dbo.Report_Dynamic @CustomerID = 27073
GO
EXEC dbo.Report_Dynamic @CustomerID = 21417
GO
EXEC dbo.Report_Dynamic @CustomerID = 29717, @SalesPersonID = 283
GO
select  [sql].[text], stats.execution_count, p.size_in_bytes
from sys.dm_exec_cached_plans p
outer apply sys.dm_exec_sql_text (p.plan_handle) sql
join sys.dm_exec_query_stats stats ON stats.plan_handle = p.plan_handle
GO
