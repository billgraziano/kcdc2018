--------------------
-- Object Creation
--------------------

DROP TABLE IF EXISTS #tmp 
CREATE TABLE #tmp (RowID INT); 

CREATE OR ALTER PROC #sproc 
AS
  BEGIN
	SELECT 1
  END
GO



--------------------------------
-- Passing CSV to procedures
--------------------------------
DECLARE @string VARCHAR(800) = '32,002,19,11'
DECLARE @tbl TABLE (v INT)

INSERT @tbl
SELECT CAST(value AS INT) 
FROM STRING_SPLIT (@string,',')

SELECT * FROM @tbl 



--------------------------------
-- FORMAT
--------------------------------
DECLARE @d DATE = '2018-07-11';
SELECT	FORMAT(@d, 'd', 'en-US') AS [en-US],
		FORMAT(@d, 'd', 'de-de') AS [de-de],
		FORMAT(@d, 'yyyy-MM-dd') AS [yyy-MM-dd]

DECLARE @I int = 234569233;
SELECT	FORMAT(@i, '#,##0')


--------------------------------
-- SEQUENCES
--------------------------------
USE [tempdb]
GO
DROP SEQUENCE IF EXISTS dbo.my_seq;
CREATE SEQUENCE dbo.my_seq
	AS INT
	START WITH 10
	INCREMENT BY 2;

DECLARE @i INT = NEXT VALUE FOR dbo.my_seq
SELECT @i AS [my_seq]

DROP TABLE IF EXISTS dbo.TestTable 
CREATE TABLE dbo.TestTAble (
	RowID INT PRIMARY KEY DEFAULT(NEXT VALUE FOR dbo.my_seq),
	RowText NVARCHAR(100) )
GO

INSERT dbo.TestTable(RowText)
VALUES ('One'), ('Two')

SELECT * FROM dbo.TestTable 


--------------------------------
-- Temporal Tables 
--------------------------------
use tempdb
GO 
IF EXISTS (SELECT * FROM SYS.TABLES WHERE object_id = OBJECT_ID('dbo.Team')   )
    ALTER TABLE [dbo].[Team] SET (SYSTEM_VERSIONING = OFF)  
GO
DROP TABLE IF EXISTS dbo.Team_History
DROP TABLE IF EXISTS dbo.Team
GO
CREATE TABLE dbo.Team   
(    
  [CountryCode] CHAR(2) NOT NULL PRIMARY KEY CLUSTERED   
  , [Name] nvarchar(100) NOT NULL  
  , [Status] nvarchar(100) NOT NULL DEFAULT ('Ok')
  , [ValidFrom] datetime2 (2) GENERATED ALWAYS AS ROW START  
  , [ValidTo] datetime2 (2) GENERATED ALWAYS AS ROW END  
  , PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)  
 )    
 WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Team_History));
 GO


INSERT dbo.Team (CountryCode, [Name])
VALUES	('de', 'Germany'),
		('us', 'USA'),
		('br', 'Brazil'),
		('ru', 'Russia'),
		('be', 'Belgium'),
		('fr', 'France'),
		('xx', 'Oooops')

SELECT * FROM dbo.Team 
SELECT * FROM dbo.Team_History 

UPDATE dbo.Team
SET	Status = 'OUT!'
WHERE CountryCode = 'us'

UPDATE dbo.Team
SET	Status = 'Also OUT'
WHERE CountryCode = 'ru'

DELETE dbo.Team
WHERE CountryCode = 'xx';

DECLARE @t DATETIME2 = GETUTCDATE()

SELECT *
FROM	dbo.Team
FOR SYSTEM_TIME AS OF @t
--FOR SYSTEM_TIME AS OF 2018-07-09 22:19:17.09

SELECT	*
FROM	dbo.Team FOR SYSTEM_TIME ALL
WHERE	CountryCode = 'us'
ORDER BY ValidFrom 




