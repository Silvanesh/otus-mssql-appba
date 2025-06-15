/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select
datepart(year,t1.[InvoiceDate]) as [Год продажи]
,datepart(month,t1.[InvoiceDate]) as [Месяц продажи]
,avg(t2a.[UnitPrice]) as [Средняя цена за месяц по всем товарам]
,sum(t3.[TransactionAmount]) as [Общая сумма продаж за месяц]
from
[WideWorldImporters].[Sales].[Invoices] t1
left join [WideWorldImporters].[Sales].[InvoiceLines] t2 on t1.InvoiceID = t2.InvoiceID
left join [WideWorldImporters].[Warehouse].[StockItems] t2a on t2.StockItemID = t2a.StockItemID
left join [WideWorldImporters].[Purchasing].[SupplierTransactions] t3 on t1.OrderID = t3.PurchaseOrderID
group by
datepart(year,t1.[InvoiceDate])
,datepart(month,t1.[InvoiceDate])


/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select
datepart(year,t1.[InvoiceDate]) as [Год продажи]
,datepart(month,t1.[InvoiceDate]) as [Месяц продажи]
,sum(t3.[TransactionAmount]) as [Общая сумма продаж]
from
[WideWorldImporters].[Sales].[Invoices] t1
left join [WideWorldImporters].[Purchasing].[SupplierTransactions] t3 on t1.OrderID = t3.PurchaseOrderID
group by
datepart(year,t1.[InvoiceDate])
,datepart(month,t1.[InvoiceDate])
having
sum(t3.[TransactionAmount]) > 4600000


/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select
datepart(year,t1.[InvoiceDate]) as [Год продажи]
,datepart(month,t1.[InvoiceDate]) as [Месяц продажи]
,t4.StockItemName as [Наименование товара]
,sum(t3.[TransactionAmount]) as [Сумма продаж]
,min(t1.[InvoiceDate]) as [Дата первой продажи]
,sum(t2.[Quantity]) as [Количество проданного]
from
[WideWorldImporters].[Sales].[Invoices] t1
left join [WideWorldImporters].[Sales].[InvoiceLines] t2 on t1.InvoiceID = t2.InvoiceID
left join [WideWorldImporters].[Sales].[CustomerTransactions] t3 on t1.[CustomerPurchaseOrderNumber] = t3.[CustomerTransactionID]
left join [WideWorldImporters].[Warehouse].[StockItems] t4 on t2.StockItemID = t4.StockItemID
group by
datepart(year,t1.[InvoiceDate])
,datepart(month,t1.[InvoiceDate])
,t4.StockItemName
having
sum(t2.[Quantity]) < 50


-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
