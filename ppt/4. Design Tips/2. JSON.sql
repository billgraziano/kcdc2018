use AdventureWorks2016
go
-- Basic Query 
DECLARE @json NVARCHAR(MAX)
SET @json =  
N'[  
       { "id" : 2,"info": { "name": "John", "surname": "Smith" }, "age": 25 },  
       { "id" : 5,"info": { "name": "Jane", "surname": "Smith" }, "dob": "2005-11-04T12:00:00" }  
 ]'  

SELECT *  
FROM OPENJSON(@json)  
  WITH (id int 'strict $.id',  
        firstName nvarchar(50) '$.info.name', 
		lastName nvarchar(50) '$.info.surname',  
        age int, 
		dateOfBirth datetime2 '$.dob')  
GO

-- Convert data to JSON
SELECT	SalesOrderNumber, OrderDate, SubTotal 
FROM	AdventureWorks2016.Sales.SalesOrderHeader
WHERE	RegionCode = 'KS'
FOR JSON PATH;

-- Use JSON stored in a table 
IF OBJECT_ID('tempdb..#person') IS NOT NULL
	DROP TABLE #person;

CREATE TABLE #person (
	PersonID INT PRIMARY KEY,
	JSONData NVARCHAR(MAX),
)

INSERT #person (PersonID, JSONData)
VALUES
	(2, '{"info": { "name": "John", "surname": "Smith" }, "age": 25 }'),
	(5, '{"info": { "name": "Jane", "surname": "Smith" }, "dob": "1993-11-04T12:00:00" }')

SELECT *, isjson(JSONData) FROM #person 

SELECT PersonID,
	JSON_VALUE(JSONData, '$.info.name') AS FirstName,
	JSON_VALUE(JSONData, '$.info.surname') AS SurName,
	JSON_VALUE(JSONData, '$.age') AS Age,
	JSON_VALUE(JSONData, '$.dob') AS DOB
FROM	#person 		

---------------------------------
-- Indexed JSON
---------------------------------
 
IF OBJECT_ID('tempdb..#person') IS NOT NULL
	DROP TABLE #person;

CREATE TABLE #person (
	PersonID INT PRIMARY KEY,
	JSONData NVARCHAR(1000),
	Age AS CAST(JSON_VALUE(JSONData, '$.age') as tinyint),
	INDEX IX_Person_Age (Age)
)

INSERT #person (PersonID, JSONData)
VALUES
	(2, '{"info": { "name": "John", "surname": "Smith" }, "age": 25 }'),
	(5, '{"info": { "name": "Jane", "surname": "Smith" }, "dob": "1993-11-04T12:00:00" }')


SELECT	*
FROM	#person 	
WHERE	Age = 25	


