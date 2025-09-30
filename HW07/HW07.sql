/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/


declare @name nvarchar(max), @sql nvarchar(max)

select @name = STRING_AGG(cast(QUOTENAME([CustomerName]) as nvarchar(max)), ', ' )  from (select distinct [CustomerName] from [WideWorldImporters].[Sales].[Customers]) as Customers;
set @sql = '

select
*
from
(select
t2.[CustomerName] as [Клиент]
,format(CAST(DATEADD(mm,DATEDIFF(mm,0,t1.[InvoiceDate]),0) AS DATE),''dd.MM.yyyy'') as month
,count(t1.[InvoiceID]) as count
   FROM [WideWorldImporters].[Sales].[Invoices] t1 
   left join [WideWorldImporters].[Sales].[Customers] t2 on t1.CustomerID = t2.CustomerID
     group by 
	 t2.[CustomerName]
	 ,CAST(DATEADD(mm,DATEDIFF(mm,0,t1.[InvoiceDate]),0) AS DATE)  ) t
	 pivot (
	 sum(t.count) for [Клиент] in (' + @name + '))as pvt;';
	

EXEC sp_executesql @sql
