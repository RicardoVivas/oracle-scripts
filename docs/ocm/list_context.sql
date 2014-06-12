SET SERVEROUTPUT ON

DECLARE
  list dbms_session.AppCtxTabTyp;
  cnt number;
BEGIN
  dbms_session.list_context (list, cnt);
  IF cnt = 0
    THEN dbms_output.put_line('No contexts active.');
    ELSE
      FOR i IN 1..cnt LOOP
        dbms_output.put_line(list(i).namespace
          ||' ' || list(i).attribute
          || ' = ' || list(i).value);
      END LOOP;
  END IF;
END;
/