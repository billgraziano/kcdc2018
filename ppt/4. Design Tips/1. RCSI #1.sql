/* SET TEXT OUTPUT  & SPLIT WINDOW */

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

WAITFOR DELAY '00:00:08';

commit TRAN

PRINT '' 
SELECT * FROM dbo.TestTable

/*

0. Set TEXT OUTPUT
1. Demo left side blocking 
	right SELECT ONLY (blocks)
2. Demo right side with NOLOCK
	- no block result

3. Enable RCSI

4. Clear NOLOCK on right, 
	- no blocking, before value
5. Enable the update 
	- bad values
6. Enable HOLDLOCK both sides
	- Blocking but good values
	- writes block writes

0. Set to text output
1. Demo  nolock
2. Demo without nolock
3. Demo same query w/RCSI 
4. Demo full tran RCSI without HOLDLOCK
5. Demo full tran RCSI HOLDLOCK on both txns
6. Turn off RCSI

*/