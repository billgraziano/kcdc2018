---------------------------------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX [IX_SalesOrderHeader_OrderDate] ON [Sales].[SalesOrderHeader]
( [OrderDate] ASC )


/*

Update a few random order headers to status 3 and one for a specific customer
 -- but only if none already exist

*/


