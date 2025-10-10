CREATE MESSAGE TYPE
[//WWI/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML;
CREATE MESSAGE TYPE
[//WWI/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 

CREATE CONTRACT [//WWI/SB/Contract]
([//WWI/SB/RequestMessage]
SENT BY INITIATOR,
[//WWI/SB/ReplyMessage]
SENT BY TARGET
);

CREATE QUEUE TargetQueueWWI;
CREATE SERVICE [//WWI/SB/TargetService]
ON QUEUE TargetQueueWWI
([//WWI/SB/Contract]);

CREATE QUEUE InitiatorQueueWWI;
CREATE SERVICE [//WWI/SB/InitiatorService]
ON QUEUE InitiatorQueueWWI
([//WWI/SB/Contract]);

create table CountOrdersCustomer
(CustomerID int
,StartDate date
,EndDdate date
,Count int)

--Создаем процедуры:
--1. SendCustomer.sql
--2. GetCustomer.sql
--3. ConfirmCustomer.sql

ALTER QUEUE [dbo].[InitiatorQueueWWI] WITH STATUS = ON --OFF=очередь НЕ доступна(ставим если глобальные проблемы)
                                          ,RETENTION = OFF --ON=все завершенные сообщения хранятся в очереди до окончания диалога
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=после 5 ошибок очередь будет отключена
	                                      ,ACTIVATION (STATUS = ON --OFF=очередь не активирует ХП(в PROCEDURE_NAME)(ставим на время исправления ХП, но с потерей сообщений)  
										              ,PROCEDURE_NAME = Sales.ConfirmCustomer
													  ,MAX_QUEUE_READERS = 1 --количество потоков(ХП одновременно вызванных) при обработке сообщений(0-32767)
													                         --(0=тоже не позовется процедура)(ставим на время исправления ХП, без потери сообщений) 
													  ,EXECUTE AS OWNER --учетка от имени которой запустится ХП
													  ) 

GO
ALTER QUEUE [dbo].[TargetQueueWWI] WITH STATUS = ON 
                                       ,RETENTION = OFF 
									   ,POISON_MESSAGE_HANDLING (STATUS = OFF)
									   ,ACTIVATION (STATUS = ON 
									               ,PROCEDURE_NAME = Sales.GetCustomer
												   ,MAX_QUEUE_READERS = 1
												   ,EXECUTE AS OWNER 
												   ) 

GO

EXEC Sales.SendCustomer
	@CustomerID = 833
	,@StartDate = '2013-01-01' 
	,@EndDate = '2014-01-01'


select
*
from 
CountOrdersCustomer


