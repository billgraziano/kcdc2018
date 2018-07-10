use tempdb
go
-- A basic exception
SELECT 1/0 ;

INSERT dbo.Junk
VALUES ('ABC');

-- With SET XACT_ABORT ON
SET XACT_ABORT ON; 
SELECT 1/0 ;

INSERT dbo.Junk
VALUES ('ABC');

-- Raise a custom error
-- Don't do this unless you want to investigate
RAISERROR('Invalid customer', 16, 1) -- this will raise a .NET SqlException


-- TRY CATCH #1 -----------------------------
BEGIN TRY
	SELECT 1/0 ;

	INSERT dbo.Junk
	VALUES ('ABC');
END TRY
BEGIN CATCH
	PRINT ERROR_NUMBER()
	PRINT ERROR_MESSAGE()
END CATCH 

--TRY CATCH with THROW -----------------------
BEGIN TRY
	SELECT 1/0 ;

	INSERT dbo.Junk
	VALUES ('ABC');
END TRY
BEGIN CATCH
	THROW
END CATCH 

