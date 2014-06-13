Rem
Rem $Header: DataAPI_Insert.sql 22-mar-2007.13:39:38 vdjegara Exp $
Rem
Rem DataAPI_Insert.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      DataAPI_Insert.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vdjegara    01/29/07 - Data Interface Insert test
Rem    vdjegara    01/29/07 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

set serverout on

CREATE OR REPLACE PROCEDURE DataAPI_Insert (LobSize NUMBER, NumRows NUMBER, Iter NUMBER, UserNum NUMBER) as
   TYPE KeysWriteBuf_Varr   IS VARRAY(1000) OF NUMBER ;		-- keep 1,000 as maximum commit batch size

   v_KeysWriteBuf  	KeysWriteBuf_Varr   := KeysWriteBuf_Varr(NULL); 

   v_LobWriteBuf 	RAW(32767);

   v_MaxAmt             PLS_INTEGER := 32767;           -- maximum allowed in plsql
   v_KeyStartValue      PLS_INTEGER := 0;
   v_NextKeyStart       PLS_INTEGER := 0;
   v_USERKEYRANGE       PLS_INTEGER := 100000;
   v_LobType            VARCHAR2(3);

   v_StartTime          PLS_INTEGER;                    -- For tracking each txn elapsed time
   v_EndTime            PLS_INTEGER;
   v_ElapsedTime        FLOAT := 0;

   v_StartTimeTot       PLS_INTEGER;                    -- For tracking total elapsed time
   v_EndTimeTot         PLS_INTEGER;
   v_ElapsedTimeTot     FLOAT := 0;

   v_StartCpuTot        PLS_INTEGER := 0;               -- For tracking total cpu time
   v_EndCpuTot          PLS_INTEGER := 0;
   v_ElapsedCpuTot      FLOAT := 0;

   v_AvgElapsed         FLOAT := 0;                     -- Average for each txn
   v_AvgCpu             FLOAT := 0;
   v_AvgRate            FLOAT := 0;

   v_GreaterThan32k	EXCEPTION;
   v_GreaterThan1k	EXCEPTION;

BEGIN
	-- for commit batch greater than 1000, increase varray size 
        IF (NumRows > 1000) THEN
 	  RAISE v_GreaterThan1k;
	END IF;

	-- since we can't write more then 32k once, any value of LobSize greater than 32k is not allowed
	IF (LobSize > 32767) THEN
	   RAISE v_GreaterThan32k;
	END IF;
	   
	v_LobWriteBuf := UTL_RAW.CAST_TO_RAW(RPAD('90', LobSize, '90'));

  	v_KeyStartValue := UserNum*v_USERKEYRANGE;
	
	-- Generate content to write into LOB column
	FOR i IN 1..NumRows LOOP
	  v_KeysWriteBuf.EXTEND;
	  v_KeysWriteBuf(i) := (i-1)+v_KeyStartValue;
	END LOOP;


     	FOR q IN 1..Iter LOOP

           IF q = 2 THEN                                -- discard q=1 as warmup
             v_StartTimeTot := dbms_utility.get_time();
             v_StartCpuTot := dbms_utility.get_cpu_time();
           END IF;

	   v_StartTime := dbms_utility.get_time();

           FOR j IN 1..NumRows LOOP
	       INSERT INTO FOO VALUES (v_KeysWriteBuf(j), v_LobWriteBuf );
           END LOOP;	-- End of NumRows 'FOR' loop
           COMMIT;

	   v_EndTime := dbms_utility.get_time();
           v_ElapsedTime := (v_EndTime-v_StartTime)*10;

           dbms_output.put_line ('Elapsed time for Iter '|| q || ' Inserted ('||NumRows||' rows) in msecs: '||v_ElapsedTime);

           IF Iter > 1 THEN
               v_NextKeyStart := v_KeyStartValue+(NumRows*(q));
               FOR i IN 1..NumRows LOOP
                   v_KeysWriteBuf(i) := (i-1)+v_NextKeyStart;
               END LOOP;
           END IF;
        END LOOP; -- End of Iter 'FOR' loop

        v_EndTimeTot := dbms_utility.get_time();
        v_EndCpuTot := dbms_utility.get_cpu_time();

        v_ElapsedTimeTot := (v_EndTimeTot-v_StartTimeTot)*10;
        v_ElapsedCpuTot := (v_EndCpuTot-v_StartCpuTot)*10;

	dbms_output.put_line ('------------------------------------------------------------------');
        dbms_output.put_line ('Total Elapsed time for write of ('||NumRows*(Iter-1)||' rows) in msecs (excluding Iter 1): '||v_ElapsedTimeTot );

	IF Iter > 1 THEN
          v_AvgElapsed := round(v_ElapsedTimeTot/(Iter-1),2);
          v_AvgCpu := round(v_ElapsedCpuTot/(Iter-1),2);
          v_AvgRate := round((LobSize*NumRows*1000)/(v_AvgElapsed*1024*1024),2);

          dbms_output.put_line ('Avg Elapsed time for a Iter ('||NumRows||' rows) in msecs (excluding Iter 1): '||v_AvgElapsed );
          dbms_output.put_line ('Avg CPU time for a Iter ('||NumRows||' rows) in msecs (excluding Iter 1): '||v_AvgCpu );
          dbms_output.put_line ('Avg Write Rate for ('||NumRows||' rows)  (excluding Iter 1) : '||v_AvgRate ||' (Mb/sec)');

        END IF;

        Select securefile into v_LobType from user_lobs where table_name='FOO' and column_name='DOCUMENT';

        IF v_LobType = 'YES' THEN
           dbms_output.put_line ('SECUREFILE Lob Write Test Finished (Using PLSQL Data API) ');
        ELSE
           dbms_output.put_line ('BASICFILE Lob Write Test Finished (Using PLSQL Data API) ');
        END IF;
        dbms_output.put_line ('Inserted LobSize='||LobSize||' bytes, NumRows or CommitSize='||NumRows ||', Iter='||Iter );
        dbms_output.put_line ('------------------------------------------------------------------');
        dbms_output.put_line ('       ');

EXCEPTION	
	WHEN v_GreaterThan32k THEN
	    dbms_output.put_line('Input Parameter ERROR ');
	    dbms_output.put_line('LobSize value of more than 32767 is not allowed..');
	WHEN v_GreaterThan1k THEN
	    dbms_output.put_line('Input Parameter ERROR ');
	    dbms_output.put_line('For NumRows greater than 1000, increase v_KeysWriteBuf varray size..');
END;
/
show errors
