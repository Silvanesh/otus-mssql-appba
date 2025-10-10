 CREATE TABLE [Sales].[Invoices2](
	[InvoiceID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[BillToCustomerID] [int] NOT NULL,
	[OrderID] [int] NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[ContactPersonID] [int] NOT NULL,
	[AccountsPersonID] [int] NOT NULL,
	[SalespersonPersonID] [int] NOT NULL,
	[PackedByPersonID] [int] NOT NULL,
	[InvoiceDate] [date] NOT NULL,
	[CustomerPurchaseOrderNumber] [nvarchar](20) NULL,
	[IsCreditNote] [bit] NOT NULL,
	[CreditNoteReason] [nvarchar](max) NULL,
	[Comments] [nvarchar](max) NULL,
	[DeliveryInstructions] [nvarchar](max) NULL,
	[InternalComments] [nvarchar](max) NULL,
	[TotalDryItems] [int] NOT NULL,
	[TotalChillerItems] [int] NOT NULL,
	[DeliveryRun] [nvarchar](5) NULL,
	[RunPosition] [nvarchar](5) NULL,
	[ReturnedDeliveryData] [nvarchar](max) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
	CONSTRAINT [PK_Sales_Invoices] PRIMARY KEY CLUSTERED 
   ([InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [USERDATA]
) ON [USERDATA] TEXTIMAGE_ON [USERDATA]



	insert into [Sales].[Invoices2]
	select
	[InvoiceID]
      ,[CustomerID]
      ,[BillToCustomerID]
      ,[OrderID]
      ,[DeliveryMethodID]
      ,[ContactPersonID]
      ,[AccountsPersonID]
      ,[SalespersonPersonID]
      ,[PackedByPersonID]
      ,[InvoiceDate]
      ,[CustomerPurchaseOrderNumber]
      ,[IsCreditNote]
      ,[CreditNoteReason]
      ,[Comments]
      ,[DeliveryInstructions]
      ,[InternalComments]
      ,[TotalDryItems]
      ,[TotalChillerItems]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[ReturnedDeliveryData]
      ,[LastEditedBy]
      ,[LastEditedWhen]
	from 
	[WideWorldImporters].[Sales].[Invoices]

ALTER DATABASE [WideWorldImporters] ADD FILEGROUP [YearData]
GO


alter database [WideWorldImporters] add filegroup [2012]
alter database [WideWorldImporters] add filegroup [2013]
alter database [WideWorldImporters] add filegroup [2014]
alter database [WideWorldImporters] add filegroup [2015]
alter database [WideWorldImporters] add filegroup [2016]
alter database [WideWorldImporters] add filegroup [2017]
go

ALTER DATABASE [WideWorldImporters] ADD FILE 
(NAME = 2012, FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL16.SQL2022\MSSQL\engine\data\2012.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [2012]
ALTER DATABASE [WideWorldImporters] ADD FILE 
(NAME = 2013, FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL16.SQL2022\MSSQL\engine\data\2012.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [2013]
ALTER DATABASE [WideWorldImporters] ADD FILE 
(NAME = 2014, FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL16.SQL2022\MSSQL\engine\data\2012.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [2014]
ALTER DATABASE [WideWorldImporters] ADD FILE 
(NAME = 2015, FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL16.SQL2022\MSSQL\engine\data\2012.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [2015]
ALTER DATABASE [WideWorldImporters] ADD FILE 
(NAME = 2016, FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL16.SQL2022\MSSQL\engine\data\2012.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [2016]
ALTER DATABASE [WideWorldImporters] ADD FILE 
(NAME = 2017, FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL16.SQL2022\MSSQL\engine\data\2012.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [2017]
GO

CREATE PARTITION FUNCTION [fnYearPartition](DATE) 
AS 
RANGE RIGHT FOR VALUES ('20120101','20130101','20140101','20150101','20160101', '20170101');
GO

CREATE PARTITION SCHEME [schmYearPartition] 
AS 
PARTITION [fnYearPartition] TO (2012,2013,2014,2015,2016,2017)
GO

alter table [Sales].[Invoices2] drop constraint PK_Sales_Invoices with (move to schmYearPartition([InvoiceDate]))