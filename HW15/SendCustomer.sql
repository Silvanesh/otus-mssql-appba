SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE Sales.SendCustomer
	@CustomerID INT
	,@StartDate date
	,@EndDate date
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage xml;
	
	BEGIN TRAN


	set @RequestMessage = (
	SELECT @CustomerID as [ID]
	,@StartDate as [StartDate]
	,@EndDate as [EndDate]
FOR XML raw('Customer'), type); 
	

	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService]
	TO SERVICE
	'//WWI/SB/TargetService'
	ON CONTRACT
	[//WWI/SB/Contract]
	WITH ENCRYPTION=OFF;


	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);
	

	
	COMMIT TRAN 
END
GO
