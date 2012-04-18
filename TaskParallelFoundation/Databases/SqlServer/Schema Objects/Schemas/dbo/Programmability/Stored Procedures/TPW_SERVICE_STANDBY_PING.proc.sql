﻿CREATE PROCEDURE dbo.TPW_SERVICE_STANDBY_PING
(
	@outSwitch_To_Mode	NVARCHAR(8)	OUTPUT
)
AS
	SET NOCOUNT ON;
	DECLARE	@tInterval		TINYINT;
	DECLARE	@tNow			DATETIME;
	DECLARE	@tPrimary_Beat	DATETIME;

	SET	@tInterval	= dbo.TPW_SERVICE_GET_STANDBY_INTERVAL();
	SET	@tNow		= GETDATE();

	UPDATE	TPW_PUMP_CONFIG
	SET		DATE_VALUE		= @tNow
	WHERE	DATE_VALUE		<= DATEADD(second, -@tInterval, @tNow)
		AND	ELEMENT_NAME	= N'STANDBY_BEAT';

	IF @@ROWCOUNT > 0
	BEGIN
		SELECT @tPrimary_Beat = DATE_VALUE FROM TPW_PUMP_CONFIG WHERE ELEMENT_NAME = N'PRIMARY_BEAT';
		IF DATEDIFF(second, @tPrimary_Beat, @tNow)	> (@tInterval / 2)
			SET	@outSwitch_To_Mode	= N'Primary';
		ELSE
			SET	@outSwitch_To_Mode	= N'Standby';
	END;

	EXEC TPW_SERVICE_SERVICE_PING 0;
