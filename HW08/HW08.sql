/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

insert into [WideWorldImporters].[Purchasing].[Suppliers] 
	  ([SupplierID]
      ,[SupplierName]
      ,[SupplierCategoryID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryPostalCode]
      ,[PostalAddressLine1]
      ,[PostalPostalCode]
      ,[LastEditedBy]
      ,[ValidFrom]
      ,[ValidTo])

values(1062, 'Tralala Lala', 2, 21, 22,	38171,	38171,	14,	'(847) 555-0100',	'(847) 555-0101',	'http://www.adatum.com',	'Suite 10',	46077,	'PO Box 1039',	46077,	1, default,	default)
,(1063, 'Tralala Vva', 2, 21, 22,	38171,	38171,	14,	'(847) 555-0100',	'(847) 555-0101',	'http://www.adatum.com',	'Suite 10',	46077,	'PO Box 1039',	46077,	1, default,	default)
,(1064, 'Tralala Gaga', 2, 21, 22,	38171,	38171,	14,	'(847) 555-0100',	'(847) 555-0101',	'http://www.adatum.com',	'Suite 10',	46077,	'PO Box 1039',	46077,	1, default,	default)
,(1065, 'Tralala Trata', 2, 21, 22,	38171,	38171,	14,	'(847) 555-0100',	'(847) 555-0101',	'http://www.adatum.com',	'Suite 10',	46077,	'PO Box 1039',	46077,	1, default,	default)
,(1066, 'Tralala Mumu', 2, 21, 22,	38171,	38171,	14,	'(847) 555-0100',	'(847) 555-0101',	'http://www.adatum.com',	'Suite 10',	46077,	'PO Box 1039',	46077,	1, default,	default)

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

delete from [WideWorldImporters].[Purchasing].[Suppliers] 
where 
[SupplierID] = 1062


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

update [WideWorldImporters].[Purchasing].[Suppliers] 
set [SupplierName] = 'Blabla'
where 
[SupplierID] = 1063

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

select
*
into #t
from
[WideWorldImporters].[Purchasing].[Suppliers] 
where
[SupplierID] in (1063,1064)

delete from [WideWorldImporters].[Purchasing].[Suppliers] 
where 
[SupplierID] = 1063

MERGE [WideWorldImporters].[Purchasing].[Suppliers]  AS Target
USING #t AS Source
    ON (Target.[SupplierID] = Source.[SupplierID])
WHEN MATCHED 
    THEN UPDATE 
        SET [SupplierName] = Source.[SupplierName]
WHEN NOT MATCHED 
    THEN INSERT 
        VALUES (Source.[SupplierID]
      ,Source.[SupplierName]
      ,Source.[SupplierCategoryID]
      ,Source.[PrimaryContactPersonID]
      ,Source.[AlternateContactPersonID]
      ,Source.[DeliveryMethodID]
      ,Source.[DeliveryCityID]
      ,Source.[PostalCityID]
      ,Source.[SupplierReference]
      ,Source.[BankAccountName]
      ,Source.[BankAccountBranch]
      ,Source.[BankAccountCode]
      ,Source.[BankAccountNumber]
      ,Source.[BankInternationalCode]
      ,Source.[PaymentDays]
      ,Source.[InternalComments]
      ,Source.[PhoneNumber]
      ,Source.[FaxNumber]
      ,Source.[WebsiteURL]
      ,Source.[DeliveryAddressLine1]
      ,Source.[DeliveryAddressLine2]
      ,Source.[DeliveryPostalCode]
      ,Source.[DeliveryLocation]
      ,Source.[PostalAddressLine1]
      ,Source.[PostalAddressLine2]
      ,Source.[PostalPostalCode]
      ,Source.[LastEditedBy]
      ,default
      ,default)
WHEN NOT MATCHED BY SOURCE
    THEN 
        DELETE
OUTPUT deleted.*, $action, inserted.*;

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

DECLARE @out varchar(250);
set @out = 'bcp [WideWorldImporters].[Purchasing].[Suppliers] OUT "D:\OTUS\test.txt" -T -c -S ' + @@SERVERNAME;
PRINT @out;

EXEC master..xp_cmdshell @out



DECLARE @in varchar(250);
set @in = 'bcp [WideWorldImporters].[Purchasing].[Suppliers] OUT "D:\OTUS\test.txt" -T -c -S ' + @@SERVERNAME;

EXEC master..xp_cmdshell @in;