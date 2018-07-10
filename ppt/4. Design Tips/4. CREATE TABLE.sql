
USE AdventureWorks2016

IF OBJECT_ID('dbo.BG_Test') IS NOT NULL
	DROP TABLE dbo.BG_Test;

CREATE TABLE dbo.BG_Test (

	SalesOrderID	INT NOT NULL
		REFERENCES Sales.SalesOrderHeader(SalesOrderID),

	ModifiedDate	DATETIME NOT NULL
		CONSTRAINT DF_BG_Test_ModifiedDate DEFAULT(GETDATE())
		INDEX IX_BG_Test_ModifiedDate,

	OrderType		tinyint NOT NULL
		CONSTRAINT CK_BG_Test_OrderType CHECK (OrderType >= 1 AND OrderType <= 5),

	TXNID			BIGINT NOT NULL
		CONSTRAINT UQ_BG_Test_TXNID UNIQUE,

	OrderDesc		AS (CAST(TXNID AS NVARCHAR(100)) + '-' + CAST(OrderType AS NVARCHAR(100)) ) PERSISTED,

	ExtraData		NVARCHAR(1000) NULL,
	ExtraDataShipper AS CAST(CASE 
				WHEN ISJSON(ExtraData) = 1 THEN JSON_VALUE(ExtraData, '$.shipper')
				ELSE NULL
			END AS NVARCHAR(100)) PERSISTED,

	CONSTRAINT PK_BG_Test PRIMARY KEY CLUSTERED (SalesOrderID),
	CONSTRAINT CK_BG_Test_TXNID_Type CHECK ((TXNID > 1000 AND OrderType <= 3) OR (TXNID <= 1000 AND OrderType <> 1) )
)

CREATE INDEX IX_BG_Test_ExtraDataShiper ON dbo.BG_Test(ExtraDataShipper);

INSERT dbo.BG_Test (SalesOrderID, OrderType, TXNID)
VALUES (43670, 3, 2234)

INSERT dbo.BG_Test (SalesOrderID, OrderType, TXNID)
VALUES (43675, 1, 500)

INSERT dbo.BG_Test (SalesOrderID, OrderType, TXNID)
VALUES (43684, 15, 500)

INSERT dbo.BG_Test (SalesOrderID, OrderType, TXNID, ExtraData)
VALUES (43724, 2, 5200, '{ "shipper":"YellowFreight"}')


SELECT	*
FROM	dbo.BG_Test

/*

UPDATE	dbo.BG_Test
SET		ExtraData = '{ "shipper":"FEDEX"}'
WHERE	SalesOrderID = 43670

*/