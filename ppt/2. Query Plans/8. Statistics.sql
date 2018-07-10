
-- List all the statistics with last updated and mod counter
SELECT 
	object_name(stat.object_id) AS [Table], 
	sp.stats_id, name, filter_definition, last_updated, rows, rows_sampled, steps, unfiltered_rows, modification_counter   
FROM sys.stats AS stat   
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp  
WHERE stat.object_id = object_id('Sales.SalesOrderHeader');  


-- Show histogram for RegionCode
-- Requires SQL Server 2016 SP1 CU2 or later
SELECT hist.step_number, hist.range_high_key, hist.range_rows, 
    hist.equal_rows, hist.distinct_range_rows, hist.average_range_rows
FROM sys.stats AS s
CROSS APPLY sys.dm_db_stats_histogram(s.[object_id], s.stats_id) AS hist
WHERE s.object_id = object_id('Sales.SalesOrderHeader')
and s.[name] = 'IX_SalesOrderHeader_RegionCode'


-- Show histogram for CustomerID
-- Requires SQL Server 2016 SP1 CU2 or later
SELECT hist.step_number, hist.range_high_key, hist.range_rows, 
    hist.equal_rows, hist.distinct_range_rows, hist.average_range_rows
FROM sys.stats AS s
CROSS APPLY sys.dm_db_stats_histogram(s.[object_id], s.stats_id) AS hist
WHERE s.object_id = object_id('Sales.SalesOrderHeader')
and s.[name] = 'IX_SalesOrderHeader_CustomerID'


