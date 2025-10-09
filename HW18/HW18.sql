--set statistics time, io on

--����������� ������, 3619 �����, ����� �� = 344 ��, ����������� ����� = 3651 ��
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

--������ ���������������� 3619 �����, ����� �� = 125 ��, ����������� ����� = 169 ��
Select 
ord.CustomerID
,det.StockItemID
,SUM(det.UnitPrice)
,SUM(det.Quantity)
,COUNT(ord.OrderID)    
FROM 
Sales.Orders AS ord
left JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID --������� inner �� left
left JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID and Inv.BillToCustomerID != ord.CustomerID AND Inv.InvoiceDate = ord.OrderDate--������� inner �� left
--JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID --�� ��������� � �������, ������ ��������� ������
--JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID --�� ��������� � �������, ������ ��������� ������
left join Warehouse.StockItems as it on It.StockItemID = det.StockItemID -- ������� ����� ������ ���������� � where
WHERE 
--Inv.BillToCustomerID != ord.CustomerID --������� � ������
/*AND (Select 
SupplierId
FROM
Warehouse.StockItems AS It
Where 
It.StockItemID = det.StockItemID
) = 12*/
it.SupplierId = 12 --������ ����������
AND (SELECT 
SUM(Total.UnitPrice*Total.Quantity)
FROM 
Sales.OrderLines AS Total
left Join Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID --������� inner �� left
WHERE 
ordTotal.CustomerID = Inv.CustomerID
) > 250000
--AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0 --������� � ������
GROUP BY 
ord.CustomerID
,det.StockItemID
ORDER BY 
ord.CustomerID
,det.StockItemID