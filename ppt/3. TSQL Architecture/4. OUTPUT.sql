DECLARE @Counter TABLE (
	Supplier VARCHAR(10) NOT NULL PRIMARY KEY
	,TxnID INT DEFAULT(0) NOT NULL )

INSERT @Counter (Supplier)
VALUES 
	('Test'),
	('KCDC'),
	('scaleSQL')

SELECT * FROM @Counter

UPDATE @Counter
SET TxnID += 1
OUTPUT inserted.Supplier, inserted.TxnID
WHERE Supplier = 'KCDC'

UPDATE @Counter
SET TxnID += 1
OUTPUT inserted.Supplier, inserted.TxnID
WHERE Supplier = 'KCDC'

UPDATE @Counter
SET TxnID += 1
OUTPUT inserted.Supplier, inserted.TxnID
WHERE Supplier = 'KCDC'

SELECT * FROM @Counter 