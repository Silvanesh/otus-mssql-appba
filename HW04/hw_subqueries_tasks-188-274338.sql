/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO: 
--через вложенный запрос
select distinct
t1.PersonID
,t1.[FullName]
from 
[WideWorldImporters].[Application].[People] t1
left join (select distinct
[SalespersonPersonID]
,[InvoiceDate]
from
[WideWorldImporters].[Sales].[Invoices]
where
[InvoiceDate] = '2015-07-04'
) t2 on t1.PersonID = t2.SalespersonPersonID
where
t1.[IsSalesperson] = 1
and t2.SalespersonPersonID is null

--через WITH
;with cte as (
select distinct
[SalespersonPersonID]
,[InvoiceDate]
from
[WideWorldImporters].[Sales].[Invoices]
where
[InvoiceDate] = '2015-07-04'
)

select distinct
t1.PersonID
,t1.[FullName]
from 
[WideWorldImporters].[Application].[People] t1
left join cte t2 on t1.PersonID = t2.SalespersonPersonID
where
t1.[IsSalesperson] = 1
and t2.SalespersonPersonID is null

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

TODO: 
--через вложенный запрос
select
[StockItemID]
,[StockItemName]
,[UnitPrice]
from
[WideWorldImporters].[Warehouse].[StockItems]
where
[UnitPrice] = (select
min([UnitPrice])
from
[WideWorldImporters].[Warehouse].[StockItems]
)

--через WITH
;with cte as(
select top 1
[StockItemID]
,[StockItemName]
,[UnitPrice]
from
[WideWorldImporters].[Warehouse].[StockItems]
order by
[UnitPrice] asc
)

select
*
from
cte

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

TODO:
--через вложенный запрос
select
*
from (select top 5
*
from
[WideWorldImporters].[Sales].[CustomerTransactions]
where
[IsFinalized] = 1
order by
[TransactionAmount] desc
) t

--через WITH
;with cte as(
select top 5
*
from
[WideWorldImporters].[Sales].[CustomerTransactions]
where
[IsFinalized] = 1
order by
[TransactionAmount] desc
)

select
*
from
cte

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

TODO:
--через вложенный запрос
--не указан метод доставки который нужно выбрать
select distinct
t3.[CityID]
,t3.[CityName]
,t4.FullName
from
[WideWorldImporters].[Sales].[Invoices] t1
left join [WideWorldImporters].[Sales].[Customers] t2 on t1.CustomerID = t2.CustomerID
left join [WideWorldImporters].[Application].[Cities] t3 on t2.DeliveryCityID = t3.CityID
left join [WideWorldImporters].[Application].[People] t4 on t1.PackedByPersonID = t4.PersonID
left join [WideWorldImporters].[Warehouse].[StockItemTransactions] t5 on t1.InvoiceID = t5.InvoiceID
left join(select
[StockItemID]
,rank()over (order by [UnitPrice] desc) rn
from
[WideWorldImporters].[Warehouse].[StockItems]
) t6 on t5.StockItemID = t6.StockItemID
where
t6.rn <= 3

--через WITH
;with cte as(
select
[StockItemID]
,rank()over (order by [UnitPrice] desc) rn
from
[WideWorldImporters].[Warehouse].[StockItems]
)

select distinct
t3.[CityID]
,t3.[CityName]
,t4.FullName
from
[WideWorldImporters].[Sales].[Invoices] t1
left join [WideWorldImporters].[Sales].[Customers] t2 on t1.CustomerID = t2.CustomerID
left join [WideWorldImporters].[Application].[Cities] t3 on t2.DeliveryCityID = t3.CityID
left join [WideWorldImporters].[Application].[People] t4 on t1.PackedByPersonID = t4.PersonID
left join [WideWorldImporters].[Warehouse].[StockItemTransactions] t5 on t1.InvoiceID = t5.InvoiceID
left join cte t6 on t5.StockItemID = t6.StockItemID
where
t6.rn <= 3
-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: 

;with cte as(
SELECT 
InvoiceId
,SUM(Quantity*UnitPrice) AS TotalSumm
FROM 
Sales.InvoiceLines
GROUP BY 
InvoiceId
HAVING 
SUM(Quantity*UnitPrice) > 27000
)

,cte2 as(
select
SUM(t1.PickedQuantity*t1.UnitPrice) AS TotalSummForPickedItems
,t1.OrderID
from
[WideWorldImporters].[Sales].[OrderLines] t1
left join [WideWorldImporters].[Sales].[Orders] t2 on t1.OrderID = t2.OrderID
where
t2.PickingCompletedWhen IS NOT NULL	
group by
t1.OrderID
)

SELECT 
t1.InvoiceID
,t1.InvoiceDate
,t2.FullName AS SalesPersonName
,t3.TotalSumm AS TotalSummByInvoice 
,t4.TotalSummForPickedItems
FROM 
Sales.Invoices t1
left join [WideWorldImporters].[Application].[People] t2 on t1.SalespersonPersonID = t2.PersonID
inner join cte t3 on t1.InvoiceID = t3.InvoiceID
left join cte2 t4 on t1.OrderID = t4.OrderID
ORDER BY 
t3.TotalSumm DESC

--не уверен насчет скорости чтения, но так, как мне кажется гораздо читаемей. Делая подзапрос в подзапросе просто тратишь время на расшифровку, что где когда делал, если вдруг надо будет потом вернутся к скрипту.

