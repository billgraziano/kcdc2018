/* SET TEXT OUTPUT */

USE Concurrency2
GO
SET NOCOUNT ON;

BEGIN TRAN

DECLARE @SequenceNumber INT;


SELECT	@SequenceNumber = SequenceNumber
FROM	dbo.TestTable 
					 --WITH (UPDLOCK)
WHERE	KeyValue = 'C3';

PRINT 'Before: ' + CAST(@SequenceNumber AS VARCHAR(100));

UPDATE	dbo.TestTable
SET		SequenceNumber = @SequenceNumber + 1
WHERE	KeyValue = 'C3'

SELECT	@SequenceNumber = SequenceNumber
FROM	dbo.TestTable 
WHERE	KeyValue = 'C3';


PRINT 'I got: ' + CAST(@SequenceNumber AS VARCHAR(100));

COMMIT TRAN

PRINT '' 
SELECT * FROM dbo.TestTable

/* 

UPDATE	dbo.TestTable
SET		SequenceNumber = SequenceNumber + 1
OUTPUT	inserted.KeyValue, inserted.SequenceNumber
WHERE	KeyValue = 'C3'


*/