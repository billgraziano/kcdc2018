CREATE TABLE [dbo].[Customer]
(
	[Id] INT NOT NULL PRIMARY KEY, 
    [Name] NVARCHAR(100) NOT NULL DEFAULT '', 
    [RegionCode] CHAR(2) NOT NULL DEFAULT 'KS', 
    [Active] BIT NOT NULL DEFAULT 1
)

GO

CREATE INDEX [IX_Customer_RegionCode] ON [dbo].[Customer] (RegionCode)
