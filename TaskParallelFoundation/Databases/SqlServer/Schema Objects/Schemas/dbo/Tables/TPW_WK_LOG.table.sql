﻿CREATE TABLE TPW_WK_LOG
(
	LOG_TIME			DATETIME	NOT NULL,
	REFER_ID			INT			NOT NULL,

	STATE_ID_OLD		SMALLINT,
	EVENT_ID			SMALLINT,
	STATE_ID_NEW		SMALLINT	NOT NULL,

	MESSAGE_			NVARCHAR(1024)
);
