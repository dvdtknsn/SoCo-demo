CREATE OR REPLACE TRIGGER soco_dev.SECURE_EMPLOYEES 
    BEFORE INSERT OR UPDATE OR DELETE ON soco_dev.EMPLOYEES 
    FOR EACH ROW 
BEGIN
  secure_dml;
END secure_employees;
/