
---------------------------------------------------------------------------------
-- How much memory is in the Cache?
---------------------------------------------------------------------------------
-- What is the cache?
SELECT  * 
FROM sys.dm_os_memory_cache_counters 
order by pages_kb DESC

-- How big is the cache?
SELECT sum(pages_kb) AS Cache_KB
	, sum(pages_kb) / 1024 AS Cache_MB
FROM sys.dm_os_memory_cache_counters  

-- How big is each piece of the cache
SELECT [name], [type], sum(pages_kb) AS Cache_KB
	, sum(pages_kb) / 1024 AS Cache_MB
FROM sys.dm_os_memory_cache_counters  
GROUP BY [name], [type]
ORDER BY sum(pages_kb) DESC


SELECT
	LEFT([name], 20) AS [Name],
	LEFT([type], 20) as [Type],
	pages_kb,
	pages_kb / 1024 AS cache_size_MB,
	entries_count,
	avg_size_kb = pages_kb / entries_count
FROM
	sys.dm_os_memory_cache_counters
WHERE 
	[type] in ('CACHESTORE_SQLCP', 'CACHESTORE_OBJCP', 'CACHESTORE_PHDR')
AND
	entries_count <> 0
ORDER BY
	pages_kb DESC


-- RUN AFTER 

-- What's in the cache?
select  TOP 10 [sql].[text], p.size_in_bytes, p.usecounts
from sys.dm_exec_cached_plans p
cross apply sys.dm_exec_sql_text (p.plan_handle) sql
order by p.usecounts DESC
GO



/*

Name                 Type                 pages_kb             cache_size_MB        entries_count        avg_size_kb
-------------------- -------------------- -------------------- -------------------- -------------------- --------------------
SQL Plans            CACHESTORE_SQLCP     2304                 2                    5                    460
Bound Trees          CACHESTORE_PHDR      200                  0                    4                    50
Object Plans         CACHESTORE_OBJCP     128                  0                    3                    42

(3 row(s) affected)



*/