﻿CREATE FUNCTION dbo.TPW_SERVICE_WF_GET_INIT_STATE
(
	@inActivity		NVARCHAR(32)
)
RETURNS	SMALLINT
AS
BEGIN
	DECLARE	@tBegin_State_ID	SMALLINT;

	SELECT @tBegin_State_ID = BEGIN_STATE_ID FROM TPW_WF_ACTIVITY WHERE ACTIVITY = @inActivity;

	RETURN @tBegin_State_ID;
END;
