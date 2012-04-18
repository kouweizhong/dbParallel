CREATE OR REPLACE VIEW XYZ.VIEW_TPW_PJOB AS
SELECT
	J.PJOB_ID,
	S.STATE_NAME					AS PJOB_STATE,
	J.TASK_ID_RECORD				AS TASK_COUNT,
	J.SCHEDULED_TIME,
	J.EXPIRY_TIME,
	J.START_TIME,
	J.END_TIME,
	J.USER_APP,
	J.USER_NAME,
	J.DESCRIPTION_
FROM
	XYZ.TPW_WF_STATE				S,
	(
		SELECT
			PJOB_ID,
			STATE_ID,
			TASK_ID_RECORD,
			SCHEDULED_TIME,
			EXPIRY_TIME,
			START_TIME,
			END_TIME,
			USER_APP,
			USER_NAME,
			DESCRIPTION_
		FROM
			XYZ.TPW_PJOB

		UNION ALL

		SELECT
			PJOB_ID,
			STATE_ID,
			TASK_ID_RECORD,
			SCHEDULED_TIME,
			EXPIRY_TIME,
			START_TIME,
			END_TIME,
			USER_APP,
			USER_NAME,
			DESCRIPTION_
		FROM
			XYZ.TPW_PJOB_ARCHIVE
	)	J
WHERE
	S.STATE_ID	= J.STATE_ID

WITH READ ONLY;
