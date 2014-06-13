/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lread.sql */

SET FEEDBACK 1
SET NUMWIDTH 10
SET PAGESIZE 24
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET DEFINE '^'

SET ECHO ON

CONNECT system/manager

DROP USER l2ldemo CASCADE;

/* Create User */
CREATE USER l2ldemo IDENTIFIED BY l2ldemo;
GRANT CONNECT, RESOURCE TO l2ldemo;

/* Create User */
CONNECT l2ldemo/l2ldemo;
SET SERVEROUTPUT ON

/* Create and Populate Table */
CREATE TABLE l2l_tab ( class_id NUMBER, lecture_notes LONG );

INSERT INTO l2l_tab VALUES ( 101, 'Lecture Notes for Class 101' );
INSERT INTO l2l_tab VALUES ( 201, 'Lecture Notes for Class 202' );


/* SQL functions */
CREATE OR REPLACE PROCEDURE sql_func_demo IS
   long_var  LONG;
   pos  NUMBER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ LOB SQL FUNCTION EXAMPLE ------------');

   SELECT lecture_notes INTO long_var FROM l2l_tab WHERE class_id = 101;

   DBMS_OUTPUT.PUT_LINE('Original Data Selected (long_var) looks like: ' || long_var );
   
   /* LIKE */
   IF ( long_var LIKE '%101') THEN
      DBMS_OUTPUT.PUT_LINE('LIKE finds pattern ''%101''');
   END IF;
   
   /* INSTR */
   pos := INSTR(long_var, 'Notes');
   DBMS_OUTPUT.PUT_LINE('INSTR() finds ''Notes'' in position : ' || pos );

   /* REPLACE */
   DBMS_OUTPUT.PUT_LINE('REPLACE() ''Notes'' WITH ''Video'' : ' || REPLACE(long_var,'Notes', 'Video'));

   /* CONCAT and || */
   DBMS_OUTPUT.PUT_LINE('CONCAT(long_var,long_var) : ' || CONCAT(long_var,long_var));
   DBMS_OUTPUT.PUT_LINE('long_var || long_var : ' || long_var || long_var);

   /* LENGTH */
   DBMS_OUTPUT.PUT_LINE('LENGTH(long_var) is : ' || LENGTH(long_var));

   /* SUBSTR */
   DBMS_OUTPUT.PUT_LINE('SUBSTR(long_var,1,7) : ' || SUBSTR(long_var,1,7));

   /* TRIM */
   DBMS_OUTPUT.PUT_LINE('TRIM(''L'' FROM long_var) : ' || TRIM('L' FROM long_var));

   /* LTRIM */
   DBMS_OUTPUT.PUT_LINE('LTRIM(long_var,''Lecture'') : ' || LTRIM(long_var,'Lecture'));

   /* RTRIM */
   DBMS_OUTPUT.PUT_LINE('RTRIM(long_var,''101'') : ' || RTRIM(long_var,'101'));

   /* LPAD */
   DBMS_OUTPUT.PUT_LINE('LPAD(long_var,40,''*'') : ' || LPAD(long_var,40,'*'));

   /* RPAD */
   DBMS_OUTPUT.PUT_LINE('RPAD(long_var,40,''*'') : ' || RPAD(long_var,40,'*'));

   /* UPPER */
   DBMS_OUTPUT.PUT_LINE('UPPER(long_var) : ' || UPPER(long_var));

   /* LOWER */
   DBMS_OUTPUT.PUT_LINE('LOWER(long_var) : ' || LOWER(long_var));
  
  
END;
/
SHOW ERRORS;

/* Executing the procedure with some SQL functions that work for LONG datatype */
BEGIN
   sql_func_demo();
END;
/

/* Migrating LONG column to LOB */
ALTER TABLE l2l_tab MODIFY ( lecture_notes CLOB );

/* After migrating from LONG column to LOB column, execute the same procedure and will get same result. */
BEGIN
   sql_func_demo();
END;
/

CONNECT system/manager

DROP USER l2ldemo CASCADE;

