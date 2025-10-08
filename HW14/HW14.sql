--подключаем модуль
CREATE ASSEMBLY CLRFunctions FROM 'C:\Users\Silvanesh\source\repos\SplitString\bin\Debug\SplitString.dll'
GO


--создаем пользовательскую функцию
CREATE FUNCTION [dbo].SplitStringCLR(@text [nvarchar](max), @delimiter [nchar](1))

RETURNS TABLE (

part nvarchar(max),

ID_ODER int

) WITH EXECUTE AS CALLER

AS 

EXTERNAL NAME CLRFunctions.UserDefinedFunctions.SplitString


--Проверяем работу
select part into #tmpIDs from SplitStringCLR('11,22,33,44', ',')

select
*
from
#tmpIDs