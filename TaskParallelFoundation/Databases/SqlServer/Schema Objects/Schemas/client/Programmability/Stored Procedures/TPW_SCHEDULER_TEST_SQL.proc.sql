﻿CREATE PROCEDURE client.TPW_SCHEDULER_TEST_SQL
(
	@inDynamic_SQL_STMT		NVARCHAR(MAX)
)
AS
	SET NOCOUNT ON;

	EXECUTE(@inDynamic_SQL_STMT);
