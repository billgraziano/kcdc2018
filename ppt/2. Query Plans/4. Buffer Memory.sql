-- Spin Up
--   SELECT * FROM AdventureWorks2014.Sales.SalesOrderHeader

---------------------------------------------------------------------------------
-- How much memory is in the Buffer Pool?
---------------------------------------------------------------------------------
select top 50 * from sys.dm_os_buffer_descriptors


-- Query for the total buffer size
select count(*) AS Buffered_Pages_Count
	,count(*) * 8192 / (1024 * 1024) as Buffer_Pool_MB
from sys.dm_os_buffer_descriptors



-- Query for the buffer pages by database
SELECT LEFT(CASE database_id 
        WHEN 32767 THEN 'ResourceDb' 
        ELSE db_name(database_id) 
        END, 20) AS Database_Name
	,count(*)AS Buffered_Page_Count -- Buffer Pool Pages
	,count(*) * 8192 / (1024 * 1024) as Buffer_Pool_MB
FROM sys.dm_os_buffer_descriptors
GROUP BY db_name(database_id) ,database_id
ORDER BY Buffered_Page_Count DESC

-- Now much of each object is in the buffer
SELECT TOP 25 
	LEFT(obj.[name], 25) AS [ObjectName],
	LEFT(i.[name], 35) AS [IndexName],
	LEFT(i.[type_desc], 12) as type_desc,
	count(*)AS cached_pages_count ,
	count(*) * 8192 / (1024 * 1024) as Buffer_MB
    -- ,obj.name ,obj.index_id, i.[name]
FROM sys.dm_os_buffer_descriptors AS bd 
    INNER JOIN 
    (
        SELECT object_name(object_id) AS name 
            ,index_id ,allocation_unit_id, object_id
        FROM sys.allocation_units AS au
            INNER JOIN sys.partitions AS p 
                ON au.container_id = p.hobt_id 
                    AND (au.type = 1 OR au.type = 3)
        UNION ALL
        SELECT object_name(object_id) AS name   
            ,index_id, allocation_unit_id, object_id
        FROM sys.allocation_units AS au
            INNER JOIN sys.partitions AS p 
                ON au.container_id = p.hobt_id 
                    AND au.type = 2
    ) AS obj 
        ON bd.allocation_unit_id = obj.allocation_unit_id
LEFT JOIN sys.indexes i on i.object_id = obj.object_id AND i.index_id = obj.index_id
WHERE database_id = db_id()
GROUP BY obj.name, obj.index_id , i.[name],i.[type_desc]
ORDER BY cached_pages_count DESC


/*

database_id     file_id     page_id  page_level   allocation_unit_id page_type                                                      row_count free_space_in_bytes is_modified
----------- ----------- ----------- ----------- -------------------- ------------------------------------------------------------ ----------- ------------------- -----------
          5           1       39429           0    72057594089766912 DATA_PAGE                                                             80                 726 0
          2           1         178           0      147932371353600 INDEX_PAGE                                                             0                8096 1
          5           1       36378           0    71800601762136064 TEXT_MIX_PAGE                                                         23                 865 0
          5           1        9814           0    71798504602664960 TEXT_MIX_PAGE                                                         20                 284 0
          5           1       69179           0    72057594090029056 INDEX_PAGE                                                           243                 806 0

(5 row(s) affected)

Cached_Pages_Count Buffer_Pool_MB
------------------ --------------
             59210            462

(1 row(s) affected)


Database_Name        Cached_Pages_Count Buffer_Pool_MB
-------------------- ------------------ --------------
sqlteam                           39101            305
tempdb                             9067             70
SQLTeamBlogsNew                    8955             69
BillGraziano                        778              6
eNewsletterPro                      675              5
ResourceDb                          419              3
master                               87              0
msdb                                 52              0
ClearPass_MIS                        51              0
model                                 9              0
ClearTrace                            8              0
clearpass_isc                         8              0

(12 row(s) affected)



ObjectName                IndexName                           type_desc    cached_pages_count Buffer_MB
------------------------- ----------------------------------- ------------ ------------------ -----------
FORUM_REPLY               IX_TOPIC_DATE                       CLUSTERED    26975              210
FORUM_TOPICS              PK_FORUM_TOPICS                     CLUSTERED    11201              87
FORUM_MEMBERS             PK_FORUM_MEMBERS                    CLUSTERED    5035               39
Impressions               Impressions                         CLUSTERED    2525               19
fulltext_index_map_341576 i1                                  CLUSTERED    1211               9
FORUM_REPLY               IX_FORUM_REPLY                      NONCLUSTERED 1201               9
FORUM_TOPICS              IX_FORUM_TOPICS_FORUM_ID_LAST_POST  NONCLUSTERED 722                5
sqlteam_Article           PK_sqlteam_Article                  CLUSTERED    583                4
sysobjvalues              clst                                CLUSTERED    532                4
tbl_BMP6_GeoData          IX_tbl_BMP6_GeoData_IP              NONCLUSTERED 473                3
fulltext_index_map_373576 i1                                  CLUSTERED    388                3
FORUM_MEMBERS_PENDING     PK__FORUM_MEMBERS_PE__46E78A0C      CLUSTERED    305                2
FORUM_TOPICS              IX_FORUM_TOPICS_TOPIC_ID            NONCLUSTERED 275                2
FORUM_MEMBERS             IX_FORUM_MEMBERS_M_IP               NONCLUSTERED 259                2
FORUM_MEMBERS             IX_FORUM_MEMBERS_M_NAME             NONCLUSTERED 257                2
FORUM_REPLY               IX_FORUM_REPLY_1                    NONCLUSTERED 200                1
FORUM_SUBSCRIPTIONS       PK_FORUM_SUBSCRIPTIONS              CLUSTERED    156                1
Impressions               aaaaaImpressions_PK                 NONCLUSTERED 110                0
FORUM_MEMBERS             IX_FORUM_MEMBERS_POSTCOUNT          NONCLUSTERED 92                 0
FORUM_SUBSCRIPTIONS       IX_SUBSCRIPTIONS_TOPIC              NONCLUSTERED 60                 0
sqlteam_ArticleHit        PK_sqlteam_ArticleHit               CLUSTERED    55                 0
FORUM_REPLY               IX_REPLY_FORUM_R_STATUS             NONCLUSTERED 50                 0
syscolpars                clst                                CLUSTERED    50                 0
FORUM_SUBSCRIPTIONS       IX_Subscriptions_Member_ID          NONCLUSTERED 38                 0
sqlmeme_URL               PK_URL_1                            CLUSTERED    29                 0

(25 row(s) affected)

*/

