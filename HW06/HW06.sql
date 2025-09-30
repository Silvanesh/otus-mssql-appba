/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

select
month
,[Sylvanite, MT]
,[Peeples Valley, AZ]
,[Medicine Lodge, KS]
,[Gasport, NY]
,[Jessie, ND]
from
(select 
SUBSTRING(t2.[CustomerName], CHARINDEX('(',t2.[CustomerName])+1,CHARINDEX(')',t2.[CustomerName])-CHARINDEX('(',t2.[CustomerName])-1) as [Клиент]
,format(CAST(DATEADD(mm,DATEDIFF(mm,0,t1.[InvoiceDate]),0) AS DATE),'dd.MM.yyyy') as month
,count(t1.[InvoiceID]) as count
   FROM [WideWorldImporters].[Sales].[Invoices] t1 
   left join [WideWorldImporters].[Sales].[Customers] t2 on t1.CustomerID = t2.CustomerID
     where t2.[CustomerID] in (2,3,4,5,6)
	 group by 
	 t2.[CustomerName]
	 ,CAST(DATEADD(mm,DATEDIFF(mm,0,t1.[InvoiceDate]),0) AS DATE) ) as t
	 pivot
	 (sum(count)
	 for [Клиент] in ([Sylvanite, MT]
,[Peeples Valley, AZ]
,[Medicine Lodge, KS]
,[Gasport, NY]
,[Jessie, ND])) as pivot12


/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

select
t1.CustomerName
,t2.DeliveryAddressLine1
from
[WideWorldImporters].[Sales].[Customers] t1
cross apply (
select distinct
t1.[DeliveryAddressLine1] 
union all
select distinct
t1.[DeliveryAddressLine2]
from 
[WideWorldImporters].[Sales].[Customers] t1
) t2
where
t1.CustomerName like '%Tailspin Toys%'

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

select
t1.CountryID
,t1.CountryName
,t2.code
from
[WideWorldImporters].[Application].[Countries] t1
left join (
select
t1.CountryID
,t1.[IsoAlpha3Code] as code
from
[WideWorldImporters].[Application].[Countries] t1
union all
select
t1.CountryID 
,cast(t1.[IsoNumericCode] as nvarchar(max))
from
[WideWorldImporters].[Application].[Countries] t1
) t2 on t1.CountryID = t2.CountryID

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select
t1.CustomerID
,t1.CustomerName
,t2.[StockItemID]
,t2.UnitPrice
,t2.OrderDate
from
[WideWorldImporters].[Sales].[Customers] t1
cross apply(
select top 2
t3.CustomerID
,t2.[UnitPrice]
,t2.[StockItemID]
,t3.OrderDate
from
[WideWorldImporters].[Sales].[OrderLines] t2
left join [WideWorldImporters].[Sales].[Orders] t3 on t2.OrderID = t3.OrderID
where 
t1.CustomerID = t3.CustomerID
order by 
t2.[UnitPrice] desc
) as t2

