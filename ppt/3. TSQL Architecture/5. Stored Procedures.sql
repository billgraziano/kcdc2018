USE tempdb
GO
CREATE OR ALTER PROC dbo.Child 
	(@Parm VARCHAR(100) )
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @passedTxn bit = 0;
	IF @@TRANCOUNT > 0 
		SET @passedTxn = 1;

	IF @Parm = 'BAD' 
		RETURN 1; -- Invalid parameter

	BEGIN TRY
		IF @passedTxn = 0 
			BEGIN TRAN;

		-- Do some complicated processing
		PRINT 'Parameter: ' + @Parm

		-- Pretend this is actual code
		IF RAND() < 0.3
			RAISERROR('Bad code', 16, 1);

		IF @passedTxn = 0 
			COMMIT TRAN;
		RETURN 0;
	END TRY
	BEGIN CATCH
		IF @passedTxn = 0 
			ROLLBACK TRAN;
		-- Log the issue here if you'd like
		-- But don't generate another exception!
		THROW
	END CATCH

END
GO