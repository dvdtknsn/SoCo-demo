CREATE OR REPLACE PROCEDURE soco_dev.MyProc2( p_rc OUT SYS_REFCURSOR )
AS
BEGIN
  OPEN p_rc FOR 
  SELECT * FROM TABLE1;
END;
/