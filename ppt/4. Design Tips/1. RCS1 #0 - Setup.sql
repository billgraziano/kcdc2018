

IF NOT EXISTS(SELECT * FROM sys.databases WHERE [name] = 'Concurrency2')
	CREATE DATABASE Concurrency2;
GO

USE [Concurrency2]
GO

IF OBJECT_ID('dbo.TestTable') IS NOT NULL
	DROP TABLE dbo.TestTable
GO

CREATE TABLE [dbo].[TestTable](
	[KeyValue] [varchar](10) NOT NULL,
	[SequenceNumber] [int] NULL,
	[KeyDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[KeyValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TestTable] ADD  DEFAULT ((1)) FOR [SequenceNumber]

ALTER TABLE [dbo].[TestTable] ADD  DEFAULT (getdate()) FOR [KeyDate]
GO
INSERT dbo.TestTable (KeyValue)
VALUES ('C1'), ('C2'), ('C3'), ('C4'), ('C5'), ('A1')



USE [master]
GO
ALTER DATABASE [Concurrency2] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
ALTER DATABASE [Concurrency2] 
	SET READ_COMMITTED_SNAPSHOT OFF
		WITH NO_WAIT
GO
ALTER DATABASE [Concurrency2] SET  MULTI_USER WITH ROLLBACK IMMEDIATE;
GO


