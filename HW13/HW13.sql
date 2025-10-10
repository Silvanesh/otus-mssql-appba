/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

CREATE FUNCTION dbo.HightSalesByCustomer()
RETURNS TABLE  
AS  
RETURN   
(  

SELECT top 1
t2.CustomerName
FROM 
[WideWorldImporters].[Sales].[CustomerTransactions] t1
left join [WideWorldImporters].[Sales].[Customers] t2 on t1.CustomerID = t2.CustomerID
--where @tablename = '[Sales].[CustomerTransactions]'
order by t1.TransactionAmount desc
);  

select
*
from
dbo.HightSalesByCustomer()


/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

CREATE PROCEDURE dbo.SearchID  @SearchID nvarchar(50)   
                              
AS   
BEGIN
SET NOCOUNT ON;  
SELECT
t2.CustomerName
,t1.InvoiceID
,sum(t3.Quantity*t3.UnitPrice)
FROM 
[WideWorldImporters].[Sales].[Invoices] t1
left join [WideWorldImporters].[Sales].[Customers] t2 on t1.CustomerID = t2.CustomerID
left join [WideWorldImporters].[Sales].[InvoiceLines] t3 on t1.InvoiceID = t3.InvoiceID
WHERE 
t1.CustomerID = @SearchID
group by
t2.CustomerName
,t1.InvoiceID
END
GO 

EXECUTE dbo.SearchID
@SearchID = 832

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

CREATE FUNCTION dbo.SearchID2 (@SearchID nvarchar(50))  
RETURNS TABLE  
AS  
RETURN   
(  
SELECT
t2.CustomerID
,t2.CustomerName
,t1.InvoiceID
,sum(t3.Quantity*t3.UnitPrice) as sum
FROM 
[WideWorldImporters].[Sales].[Invoices] t1
left join [WideWorldImporters].[Sales].[Customers] t2 on t1.CustomerID = t2.CustomerID
left join [WideWorldImporters].[Sales].[InvoiceLines] t3 on t1.InvoiceID = t3.InvoiceID
WHERE 
t1.CustomerID = @SearchID
group by
t2.CustomerName
,t1.InvoiceID
,t2.CustomerID
);  

select
*
from
dbo.SearchID2 (832)


EXECUTE dbo.SearchID
@SearchID = 832

--Функция не компелируется заранее, в отличие от процедуры.


/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

--Используем функцию из прошлого примера
select
t1.CustomerID
,t2.CustomerName
,t2.InvoiceID
,t2.sum
from
[WideWorldImporters].[Sales].[Customers] t1
CROSS APPLY dbo.SearchID2 (t1.CustomerID) t2

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
