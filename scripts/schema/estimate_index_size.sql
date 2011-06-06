set serveroutput on 

declare
ub number;
ab number;
begin

DBMS_SPACE.CREATE_INDEX_COST ('CREATE INDEX "&&SCHEMA"."IDX_EST" ON "&&SCHEMA"."&TABLE_NAME" (&COLUMNS)', ub, ab);

DBMS_OUTPUT.PUT_LINE('Used Bytes: ' || TO_CHAR(ub)); 
DBMS_OUTPUT.PUT_LINE('Alloc Bytes: ' || TO_CHAR(ab)); 
END;
/

