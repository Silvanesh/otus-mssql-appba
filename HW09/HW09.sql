/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

DECLARE @xmlDocument XML;

SELECT @xmlDocument = BulkColumn
FROM OPENROWSET(BULK 'D:\OTUS\StockItems-188-1fb5df.xml', SINGLE_CLOB) as t

SELECT @xmlDocument AS [@xmlDocument];

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;

SELECT @docHandle AS docHandle

SELECT *
into #t
FROM OPENXML(@docHandle, N'/StockItems/Item')
with (
[StockItemName] nvarchar(100) '@Name'
,[SupplierID] int 'SupplierID'
,[UnitPackageID] int 'Package/UnitPackageID'
,[OuterPackageID] int 'Package/OuterPackageID'
,[QuantityPerOuter] int 'Package/QuantityPerOuter'
,[TypicalWeightPerUnit] decimal(18,3) 'Package/TypicalWeightPerUnit'
,[LeadTimeDays] int 'LeadTimeDays'
,[IsChillerStock] bit 'IsChillerStock'
,[TaxRate] decimal(18,3) 'TaxRate'
,[UnitPrice] decimal(18,2) 'UnitPrice'
)

EXEC sp_xml_removedocument @docHandle;

select
*
from #t

MERGE [WideWorldImporters].[Warehouse].[StockItems]  AS Target
USING #t AS Source
    ON (Target.[StockItemName] = Source.[StockItemName])
WHEN MATCHED 
    THEN UPDATE 
        SET [SupplierID] = Source.[SupplierID]
		,[UnitPackageID] = Source.[UnitPackageID]
		,[OuterPackageID] = Source.[OuterPackageID]
		,[QuantityPerOuter] = Source.[QuantityPerOuter]
		,[TypicalWeightPerUnit] = Source.[TypicalWeightPerUnit]
		,[LeadTimeDays] = Source.[LeadTimeDays]
		,[IsChillerStock] = Source.[IsChillerStock]
		,[TaxRate] = Source.[TaxRate]
		,[UnitPrice] = Source.[UnitPrice]
WHEN NOT MATCHED 
    THEN INSERT 
        VALUES (
		Source.[StockItemName]
		,Source.[SupplierID]
		,Source.[UnitPackageID]
		,Source.[OuterPackageID]
		,Source.[QuantityPerOuter]
		,Source.[TypicalWeightPerUnit]
		,Source.[LeadTimeDays]
		,Source.[IsChillerStock]
		,Source.[TaxRate]
		,Source.[UnitPrice])
WHEN NOT MATCHED BY SOURCE
    THEN 
        DELETE
OUTPUT deleted.*, $action, inserted.*;



DECLARE @x XML
SET @x = (
		SELECT *
		FROM OPENROWSET(BULK 'D:\OTUS\StockItems-188-1fb5df.xml', SINGLE_BLOB) AS d
		)
SELECT 
[StockItemName] = t.Items.value('(@Name)[1]', 'varchar(100)')
,[SupplierID] = t.Items.value('(SupplierID)[1]', 'int')
,[UnitPackageID]  = t.Items.value('(Package/UnitPackageID)[1]', 'int')
,[OuterPackageID] = t.Items.value('(Package/OuterPackageID)[1]', 'int')
,[QuantityPerOuter] = t.Items.value('(Package/QuantityPerOuter)[1]', 'int')
,[TypicalWeightPerUnit] = t.Items.value('(Package/TypicalWeightPerUnit)[1]', 'decimal(18,3)')
,[LeadTimeDays] = t.Items.value('(LeadTimeDays)[1]', 'int')
,[IsChillerStock] = t.Items.value('(IsChillerStock)[1]', 'bit')
,[TaxRate] = t.Items.value('(TaxRate)[1]', 'decimal(18,3)')
,[UnitPrice] = t.Items.value('(UnitPrice)[1]', 'decimal(18,2)')
FROM @x.nodes('/StockItems/Item') AS t(Items)


/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

SELECT 
StockItemName AS [Item/@Name]
,[SupplierID] AS [Item/SupplierID]
,[SupplierID] as [Item/SupplierID]
,[UnitPackageID] as [Item/Package/UnitPackageID]
,[OuterPackageID] as [Item/Package/OuterPackageID]
,[QuantityPerOuter] as [Item/Package/QuantityPerOuter]
,[TypicalWeightPerUnit] as [Item/Package/TypicalWeightPerUnit]
,[LeadTimeDays] as [Item/LeadTimeDays]
,[IsChillerStock] as [Item/IsChillerStock]
,[TaxRate] as [Item/TaxRate]
,[UnitPrice] as [Item/UnitPrice]
FROM 
[WideWorldImporters].[Warehouse].[StockItems]
FOR XML PATH('Item'), ROOT('StockItems')
GO


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT 
[StockItemID]
,[StockItemName]
,JSON_VALUE(CustomFields, '$.CountryOfManufacture')
,JSON_VALUE(CustomFields, '$.Tags[0]')
FROM 
[WideWorldImporters].[Warehouse].[StockItems]


/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

SELECT 
[StockItemID]
,[StockItemName]
,JSON_QUERY(CustomFields, '$.Tags')
FROM 
[WideWorldImporters].[Warehouse].[StockItems]
cross apply openjson(CustomFields, '$.Tags') tags
where
tags.value = 'Vintage'
