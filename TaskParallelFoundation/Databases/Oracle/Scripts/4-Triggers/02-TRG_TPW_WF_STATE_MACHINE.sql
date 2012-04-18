CREATE OR REPLACE TRIGGER XYZ.TRG_TPW_WF_STATE_MACHINE
BEFORE INSERT OR UPDATE ON XYZ.TPW_WF_STATE_MACHINE
FOR EACH ROW
BEGIN
	XYZ.TPW_SERVICE.CHECK_STATE_ID_NAME(:new.STATE_ID_OLD, :new.ACTIVITY, :new.STATE_NAME_OLD);
	XYZ.TPW_SERVICE.CHECK_EVENT_ID_NAME(:new.EVENT_ID, :new.ACTIVITY, :new.EVENT_NAME);
	XYZ.TPW_SERVICE.CHECK_STATE_ID_NAME(:new.STATE_ID_NEW, :new.ACTIVITY, :new.STATE_NAME_NEW);
END;
