/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select
[StockItemID] as [ИД товара]
,[StockItemName] as [Наименование товара]
from
[WideWorldImporters].[Warehouse].[StockItems]
where
[StockItemName] like '%urgent%'
or [StockItemName] like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select
t1.[SupplierID] as [ИД поставщика]
,t1.[SupplierName] as [Наименование поставщика]
from
[WideWorldImporters].[Purchasing].[Suppliers] t1
left join [WideWorldImporters].[Purchasing].[PurchaseOrders] t2 on t1.[SupplierID] = t2.[SupplierID]
where
t2.[SupplierID] is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select --сцепка с [Sales].[OrderLines] потенциально множит строки, в условиях задачи нет указания на вывод уникальных значений, если нужно вывести уникальные - следует добавить distinct
t1.[OrderID] as [Заказы]
,convert(varchar, t1.[OrderDate], 104) as [Дата заказа]
,datename(month, t1.[OrderDate]) as [Название месяца]
,datepart(quarter, t1.[OrderDate]) as [Номер квартала]
,case when datepart(month, t1.[OrderDate]) in (1,2,3,4) then 1 when datepart(month, t1.[OrderDate]) in (5,6,7,8) then 2 when datepart(month, t1.[OrderDate]) in (9,10,11,12) then 3 else null end  as [Треть года]
,t3.[CustomerName] as [Имя заказчика]
from 
[WideWorldImporters].[Sales].[Orders] t1
left join [WideWorldImporters].[Sales].[OrderLines] t2 on t1.[OrderID] = t2.[OrderID]
left join [WideWorldImporters].[Sales].[Customers] t3 on t1.[CustomerID] = t3.[CustomerID]
where
t2.[UnitPrice] > 100
or (t2.[Quantity] > 20
and t2.[PickingCompletedWhen] is not null) --из текста задания не понятно, это условие только в случае, когда Quantity > 20 или всегда
order by
[Номер квартала] asc, [Треть года] asc, [Дата заказа] asc
offset 1000 rows
fetch next 100 rows only

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select
t3.[DeliveryMethodName] as [Способ доставки]
,t1.[ExpectedDeliveryDate] as [Дата доставки]
,t2.[SupplierName] as [Имя поставщика]
,t4.[FullName] as [Имя контактного лица принимавшего заказ]
from
[WideWorldImporters].[Purchasing].[PurchaseOrders] t1
left join [WideWorldImporters].[Purchasing].[Suppliers] t2 on t1.[SupplierID] = t2.[SupplierID]
left join [WideWorldImporters].[Application].[DeliveryMethods] t3 on t1.[DeliveryMethodID] = t3.[DeliveryMethodID]
left join [WideWorldImporters].[Application].[People] t4 on t1.[ContactPersonID] = t4.[PersonID]
where
datepart(month, t1.[ExpectedDeliveryDate]) = 1
and datepart(year, t1.[ExpectedDeliveryDate]) = 2013
and t3.[DeliveryMethodName] in ('Air Freight', 'Refrigerated Air Freight')
and t1.[IsOrderFinalized] = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top (10) --не понятно, как поступать если в топ 10 попадают не все с одинаковой датой, если надо всех, тогда добавляет with ties
t1.[OrderID] as [Продажа]
,t2.[CustomerName] as [Имя клиента]
,t3.[FullName] as [Имя сотрудника]
from
[WideWorldImporters].[Sales].[Orders] t1
left join [WideWorldImporters].[Sales].[Customers] t2 on t1.[CustomerID] = t2.[CustomerID]
left join [WideWorldImporters].[Application].[People] t3 on t1.[SalespersonPersonID] = t3.[PersonID]
order by
[OrderDate] desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select --Не понятно, нужны уникальные данные или все. Если уникальные - добавляем distinct
t1.[CustomerID] as [ИД Клиента]
,t2.[CustomerName] as [Имя клиента]
,t2.[PhoneNumber] as [Телефон клиента]
from
[WideWorldImporters].[Sales].[Orders] t1
left join [WideWorldImporters].[Sales].[Customers] t2 on t1.[CustomerID] = t2.[CustomerID]
left join [WideWorldImporters].[Sales].[OrderLines] t3 on t1.[OrderID] = t3.[OrderID]
left join [WideWorldImporters].[Warehouse].[StockItems] t4 on t3.[StockItemID] = t4.[StockItemID]
where
t4.[StockItemName] = 'Chocolate frogs 250g'
