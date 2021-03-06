CREATE OR REPLACE PACKAGE XYZ.TPW_CALL IS

----------------------------------------------------------------------------------------------------
--
--	Copyright 2012 Abel Cheng
--	This source code is subject to terms and conditions of the Apache License, Version 2.0.
--	See http://www.apache.org/licenses/LICENSE-2.0.
--	All other rights reserved.
--	You must not remove this notice, or any other, from this software.
--
--	Original Author:	Abel Cheng <abelcys@gmail.com>
--	Created Date:		2012-03-23
--	Primary Host:		http://dbParallel.codeplex.com
--	Change Log:
--	Author				Date			Comment
--
--
--
--
--	(Keep clean code rather than complicated code plus long comments.)
--
----------------------------------------------------------------------------------------------------

FUNCTION CREATE_PJOB
(
	inUser_App			VARCHAR2	:= '',
	inUser_Name			VARCHAR2	:= '',
	inDescription		VARCHAR2	:= ''
)	RETURN				PLS_INTEGER;


PROCEDURE ADD_TASK
(
	inPJob_ID			PLS_INTEGER,
	inDynamic_SQL_STMT	CLOB,
	inCommand_Timeout	PLS_INTEGER	:= 600,
	inDescription		VARCHAR2	:= ''
);

PROCEDURE ADD_CALLBACK_FOR_SUCCESS
(
	inPJob_ID			PLS_INTEGER,
	inDynamic_SQL_STMT	CLOB,
	inCommand_Timeout	PLS_INTEGER	:= 600,
	inDescription		VARCHAR2	:= ''
);

PROCEDURE ADD_CALLBACK_FOR_FAIL
(
	inPJob_ID			PLS_INTEGER,
	inDynamic_SQL_STMT	CLOB,
	inCommand_Timeout	PLS_INTEGER	:= 600,
	inDescription		VARCHAR2	:= ''
);


PROCEDURE START_PJOB
(
	inPJob_ID			PLS_INTEGER,
	inScheduled_Time	DATE		:= SYSDATE
);


PROCEDURE TRY_CANCEL_PJOB
(
	inPJob_ID			PLS_INTEGER,
	outCancelled		OUT BOOLEAN
);


PROCEDURE WAIT_PJOB
(
	inPJob_ID		PLS_INTEGER
);


PROCEDURE START_NEW_SINGLE_TASK
(
	inDynamic_SQL		CLOB,
	inCommand_Timeout	PLS_INTEGER	:= 600,
	inSuccess_Callback	CLOB		:= NULL,
	inFail_Callback		CLOB		:= NULL,
	inUser_App			VARCHAR2	:= '',
	inUser_Name			VARCHAR2	:= '',
	inDescription		VARCHAR2	:= ''
);


PROCEDURE TEST_SQL
(
	inDynamic_SQL_STMT	CLOB
);


END TPW_CALL;
/
CREATE OR REPLACE PACKAGE BODY XYZ.TPW_CALL IS

g_Expiry_Day	NUMBER;

FUNCTION GET_EXPIRY_DAY
RETURN	NUMBER
AS
BEGIN
	IF g_Expiry_Day IS NULL THEN
		SELECT	NUMBER_VALUE		INTO g_Expiry_Day
		FROM	XYZ.TPW_PUMP_CONFIG
		WHERE	ELEMENT_NAME = 'EXPIRY_DAY';
	END IF;
	RETURN g_Expiry_Day;
END GET_EXPIRY_DAY;


FUNCTION CREATE_PJOB
(
	inUser_App		VARCHAR2	:= '',
	inUser_Name		VARCHAR2	:= '',
	inDescription	VARCHAR2	:= ''
)	RETURN			PLS_INTEGER
AS
	tPJob_ID		PLS_INTEGER	:= XYZ.TPW_SERVICE.NEXT_PJOB_ID;
	tState_ID		PLS_INTEGER	:= XYZ.TPW_SERVICE.WF_GET_INIT_STATE('TPW_PJOB');
BEGIN
	INSERT INTO XYZ.TPW_PJOB (PJOB_ID, STATE_ID, USER_APP, USER_NAME, DESCRIPTION_)
	VALUES (tPJob_ID, tState_ID, inUser_App, inUser_Name, inDescription);

	XYZ.TPW_SERVICE.WF_LOG(tPJob_ID, NULL, NULL, tState_ID, inUser_Name || ' Created PJob');

	COMMIT;
	RETURN tPJob_ID;
END CREATE_PJOB;


PROCEDURE ADD_TASK
(
	inPJob_ID			PLS_INTEGER,
	inDynamic_SQL_STMT	CLOB,
	inCommand_Timeout	PLS_INTEGER	:= 600,
	inDescription		VARCHAR2	:= ''
)
AS
	tTask_ID			PLS_INTEGER	:= XYZ.TPW_SERVICE.NEXT_TASK_ID(inPJob_ID);
BEGIN
	XYZ.TPW_SERVICE.ADD_TASK(inPJob_ID, tTask_ID, inDynamic_SQL_STMT, inCommand_Timeout, inDescription);
END ADD_TASK;

PROCEDURE ADD_CALLBACK_FOR_SUCCESS
(
	inPJob_ID			PLS_INTEGER,
	inDynamic_SQL_STMT	CLOB,
	inCommand_Timeout	PLS_INTEGER	:= 600,
	inDescription		VARCHAR2	:= ''
)	AS
BEGIN
	XYZ.TPW_SERVICE.ADD_TASK(inPJob_ID, 0, inDynamic_SQL_STMT, inCommand_Timeout, inDescription);
END ADD_CALLBACK_FOR_SUCCESS;

PROCEDURE ADD_CALLBACK_FOR_FAIL
(
	inPJob_ID			PLS_INTEGER,
	inDynamic_SQL_STMT	CLOB,
	inCommand_Timeout	PLS_INTEGER	:= 600,
	inDescription		VARCHAR2	:= ''
)	AS
BEGIN
	XYZ.TPW_SERVICE.ADD_TASK(inPJob_ID, -1, inDynamic_SQL_STMT, inCommand_Timeout, inDescription);
END ADD_CALLBACK_FOR_FAIL;


PROCEDURE START_PJOB
(
	inPJob_ID			PLS_INTEGER,
	inScheduled_Time	DATE	:= SYSDATE
)	AS
	tExpiry_Time		DATE	:= inScheduled_Time + GET_EXPIRY_DAY;
BEGIN
	XYZ.TPW_SERVICE.ON_PJOB_EVENT(inPJob_ID, 'START');

	UPDATE XYZ.TPW_PJOB
	SET
		SCHEDULED_TIME	= inScheduled_Time,
		EXPIRY_TIME		= tExpiry_Time
	WHERE
		PJOB_ID			= inPJob_ID;

	COMMIT;
END START_PJOB;


PROCEDURE TRY_CANCEL_PJOB
(
	inPJob_ID		PLS_INTEGER,
	outCancelled	OUT BOOLEAN
)	AS
	tEvent_Name		CONSTANT VARCHAR2(32)	:= 'CANCEL';
BEGIN
	XYZ.TPW_SERVICE.ON_PJOB_EVENT(inPJob_ID, tEvent_Name);
	COMMIT;
	outCancelled := TRUE;
EXCEPTION
	WHEN OTHERS THEN
		outCancelled := FALSE;
END TRY_CANCEL_PJOB;


PROCEDURE WAIT_PJOB
(
	inPJob_ID		PLS_INTEGER
)	AS
BEGIN
	XYZ.TPW_SERVICE.WAIT_PJOB(inPJob_ID);
END ;


PROCEDURE START_NEW_SINGLE_TASK
(
	inDynamic_SQL		CLOB,
	inCommand_Timeout	PLS_INTEGER	:= 600,
	inSuccess_Callback	CLOB		:= NULL,
	inFail_Callback		CLOB		:= NULL,
	inUser_App			VARCHAR2	:= '',
	inUser_Name			VARCHAR2	:= '',
	inDescription		VARCHAR2	:= ''
)	AS
	tPJob_ID			PLS_INTEGER	:= CREATE_PJOB(inUser_App, inUser_Name, inDescription);
BEGIN
	ADD_TASK(tPJob_ID, inDynamic_SQL, inCommand_Timeout);

	IF inSuccess_Callback IS NOT NULL THEN
		ADD_CALLBACK_FOR_SUCCESS(tPJob_ID, inSuccess_Callback, inCommand_Timeout);
	END IF;

	IF inFail_Callback IS NOT NULL THEN
		ADD_CALLBACK_FOR_FAIL(tPJob_ID, inFail_Callback, inCommand_Timeout);
	END IF;

	START_PJOB(tPJob_ID);
END START_NEW_SINGLE_TASK;


PROCEDURE TEST_SQL
(
	inDynamic_SQL_STMT	CLOB
)
AS
BEGIN
	EXECUTE IMMEDIATE XYZ.TPW_SERVICE.WRAP_SQL_STMT(inDynamic_SQL_STMT);
END TEST_SQL;


END TPW_CALL;
/
