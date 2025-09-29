/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

select
t1.[InvoiceID] as [id продажи]
,t2.[CustomerName] as [название клиента]
,t3.TransactionDate as [дата продажи]
,t3.[TransactionAmount] as [сумма продаж]
,(select sum(t3a.[TransactionAmount]) from [WideWorldImporters].[Sales].[CustomerTransactions] t3a where t3.CustomerID=t3a.CustomerID and month(t3.TransactionDate) >= month(t3a.TransactionDate) and year(t3.TransactionDate) >= year(t3a.TransactionDate) and t3a.[TransactionTypeID] = 1 and year(t3a.TransactionDate) >=2015) as [сумма нарастающим итогом]
from
[WideWorldImporters].[Sales].[Invoices] t1
left join [WideWorldImporters].[Sales].[Customers] t2 on t1.CustomerID = t2.CustomerID
left join [WideWorldImporters].[Sales].[CustomerTransactions] t3 on t1.[InvoiceID] = t3.[InvoiceID]
where
t3.[TransactionTypeID] = 1
and year(t3.TransactionDate) >=2015

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

select
t1.[InvoiceID] as [id продажи]
,t2.[CustomerName] as [название клиента]
,t3.TransactionDate as [дата продажи]
,month(t3.TransactionDate)
,t3.[TransactionAmount] as [сумма продаж]
,sum(t3.[TransactionAmount]) over(order by year(t3.TransactionDate), month(t3.TransactionDate)) as [сумма нарастающим итогом]
from
[WideWorldImporters].[Sales].[Invoices] t1
left join [WideWorldImporters].[Sales].[Customers] t2 on t1.CustomerID = t2.CustomerID
left join [WideWorldImporters].[Sales].[CustomerTransactions] t3 on t1.[InvoiceID] = t3.[InvoiceID]
where
t3.[TransactionTypeID] = 1
and year(t3.TransactionDate) >=2015
order by t3.TransactionDate
/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

  with cte as(
  select
  month(t1.OrderDate) as Месяц
  ,t2.[Description] as Название
  ,sum(t2.[Quantity]) as сумма
 from [WideWorldImporters].[Sales].[Orders] t1
 left join [WideWorldImporters].[Sales].[OrderLines] t2 on t1.[OrderID] = t2.[OrderID]
 where 
 year(t1.OrderDate) = 2016
 group by
   month(t1.OrderDate)
  ,t2.[Description]
  )

  ,cte2 as(
  select
  Месяц
  ,Название
  ,rank()over(partition by месяц order by сумма desc) as rank
  from cte
  )

  select
  Месяц
  ,Название
  from
  cte2
  where rank in (1,2)

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

select
t1.[StockItemID] as [ID товара]
,t1.[StockItemName] as [Название]
,t1.[Brand] as [Брэнд]
,t1.[UnitPrice] as [Цена]
,row_number() over (partition by left(t1.[StockItemName], 1) order by t1.[StockItemName]) as [Нумирация]
,(select count(t1.[StockItemID]) from  [WideWorldImporters].[Warehouse].[StockItems] t1) as [Общие количество товаров]
,count(t1.[StockItemID]) over (partition by left(t1.[StockItemName], 1)) as [Общие количество товаров по первой букве]
,lead(t1.[StockItemID],1) over (order by t1.[StockItemName]) as [Следующий товар]
,lag(t1.[StockItemID],1) over (order by t1.[StockItemName]) as [Прошлый товар]
,lag(t1.[StockItemName],2,'No items') over (order by t1.[StockItemName]) as [два товара назад]
,ntile(30)over(partition by t1.[TypicalWeightPerUnit] order by t1.[StockItemName]) as [Группы по весу]
from
[WideWorldImporters].[Warehouse].[StockItems] t1

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

  select distinct
  t4.PersonID as [ID продавца]
  ,t4.FullName as [Имя продавца]
  ,first_value(t1.[CustomerID]) over (partition by t1.[SalespersonPersonID] order by t1.[InvoiceDate] desc) [ID Покупателя]
  ,first_value(t2.CustomerName) over (partition by t1.[SalespersonPersonID] order by t1.[InvoiceDate] desc) [Имя покупателя]
  ,first_value(t1.[InvoiceDate]) over (partition by t1.[SalespersonPersonID] order by t1.[InvoiceDate] desc) as [Дата продажи]
  ,first_value(t3.TransactionAmount) over (partition by t1.[SalespersonPersonID] order by t1.[InvoiceDate] desc) as [Сумма продажи]
  from 
  [WideWorldImporters].[Sales].[Invoices] t1
  left join [WideWorldImporters].[Sales].[Customers] t2 on t1.CustomerID = t2.CustomerID
  left join [WideWorldImporters].[Sales].[CustomerTransactions] t3 on t1.InvoiceID = t3.InvoiceID
  left join [WideWorldImporters].[Application].[People] t4 on t1.SalespersonPersonID = t4.PersonID
  where
  t3.[TransactionTypeID] = 1

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

  with cte as(
  select distinct
  t1.CustomerID
  ,t1.OrderID
  ,t2.[Description]
  ,t2.[UnitPrice]
  ,t1.OrderDate
  ,rank() over (partition by t1.CustomerID order by t2.UnitPrice desc) as rank
  from 
  [WideWorldImporters].[Sales].[Orders] t1
  left join [WideWorldImporters].[Sales].[OrderLines] t2 on t1.OrderID = t2.OrderID
  )

  select
  t1.CustomerID as [ID Покупателя]
  ,t2.CustomerName as [Имя покупателя]
  ,t1.Description as [Название товара]
  ,t1.UnitPrice as [Цена товара]
  ,t1.OrderDate as [Дата покупки]
  from 
  cte t1
  left join [WideWorldImporters].[Sales].[Customers] t2 on t1.CustomerID = t2.CustomerID
  where
  t1.rank in (1,2)

--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 