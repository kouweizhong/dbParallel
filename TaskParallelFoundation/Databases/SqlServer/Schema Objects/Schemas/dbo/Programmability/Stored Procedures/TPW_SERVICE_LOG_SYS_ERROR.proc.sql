﻿CREATE PROCEDURE dbo.TPW_SERVICE_LOG_SYS_ERROR
(
	@inReference	NVARCHAR(256),
	@inMessage		NVARCHAR(4000)
)
AS
	SET NOCOUNT ON;

	INSERT INTO TPW_SYS_ERROR (LOG_TIME, REFERENCE_, MESSAGE_)
	VALUES (GETDATE(), @inReference, @inMessage);
