create PROCEDURE Sales.GetCustomer
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message xml,
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@CustomerID INT,
			@StartDate date,
			@EndDate date,
			@xml XML; 
	
	BEGIN TRAN; 


	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueWWI;


	SET @xml = @Message;


	SET @CustomerID = @xml.value('(/Customer/@ID)[1]', 'INT');
    SET @StartDate = @xml.value('(/Customer/@StartDate)[1]', 'DATE');
    SET @EndDate = @xml.value('(/Customer/@EndDate)[1]', 'DATE');



	insert into CountOrdersCustomer
select
CustomerID
,@StartDate
,@EndDate
,count(OrderID)
from
Sales.Invoices
where
CustomerID = @CustomerID
and InvoiceDate between @StartDate and @EndDate
group by
CustomerID

	
	

	IF @MessageType=N'//WWI/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>';

		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;
		             
	END 
	

	COMMIT TRAN;
END
