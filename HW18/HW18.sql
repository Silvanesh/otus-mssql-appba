--set statistics time, io on

--Изначальная версия, 3619 строк, время ЦП = 344 мс, затраченное время = 3651 мс
Select 
ord.CustomerID
,det.StockItemID
,SUM(det.UnitPrice)
,SUM(det.Quantity)
,COUNT(ord.OrderID)    
FROM 
Sales.Orders AS ord
JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
WHERE 
Inv.BillToCustomerID != ord.CustomerID
AND (Select 
SupplierId
FROM
Warehouse.StockItems AS It
Where 
It.StockItemID = det.StockItemID
) = 12
AND (SELECT 
SUM(Total.UnitPrice*Total.Quantity)
FROM 
Sales.OrderLines AS Total
Join Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID
WHERE 
ordTotal.CustomerID = Inv.CustomerID
) > 250000
AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY 
ord.CustomerID
,det.StockItemID
ORDER BY 
ord.CustomerID
,det.StockItemID

--версия оптимизированная 3619 строк, время ЦП = 125 мс, затраченное время = 169 мс
Select 
ord.CustomerID
,det.StockItemID
,SUM(det.UnitPrice)
,SUM(det.Quantity)
,COUNT(ord.OrderID)    
FROM 
Sales.Orders AS ord
left JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID --поменял inner на left
left JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID and Inv.BillToCustomerID != ord.CustomerID AND Inv.InvoiceDate = ord.OrderDate--поменял inner на left
--JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID --не участвует в запросе, только дублирует данные
--JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID --не участвует в запросе, только дублирует данные
left join Warehouse.StockItems as it on It.StockItemID = det.StockItemID -- добавил джойн вместо подзапроса в where
WHERE 
--Inv.BillToCustomerID != ord.CustomerID --перенес в сцепку
/*AND (Select 
SupplierId
FROM
Warehouse.StockItems AS It
Where 
It.StockItemID = det.StockItemID
) = 12*/
it.SupplierId = 12 --вместо подзапроса
AND (SELECT 
SUM(Total.UnitPrice*Total.Quantity)
FROM 
Sales.OrderLines AS Total
left Join Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID --поменял inner на left
WHERE 
ordTotal.CustomerID = Inv.CustomerID
) > 250000
--AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0 --перенес в сцепку
GROUP BY 
ord.CustomerID
,det.StockItemID
ORDER BY 
ord.CustomerID
,det.StockItemID