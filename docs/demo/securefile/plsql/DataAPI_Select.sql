Rem
Rem $Header: DataAPI_Select.sql 22-mar-2007.13:39:40 vdjegara Exp $
Rem
Rem DataAPI_Select.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      DataAPI_Select.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vdjegara    01/29/07 - Data Interface Select test
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

CREATE OR REPLACE PROCEDURE DataAPI_Select (LobSize NUMBER, NumRows NUMBER, Iter NUMBER, UserNum NUMBER) as

   v_LobReadBuf 	RAW(32767);

   v_MaxAmt             PLS_INTEGER := 32767;           -- maximum allowed in plsql
   v_USERKEYRANGE       PLS_INTEGER := 100000;      
   v_KeyStartValue      PLS_INTEGER := 0;               -- derived from USERKEYRANGE * UserNum
   v_KeyMaxValue        PLS_INTEGER := 0;               -- derived from StartValue + NumRows*Iter
   v_KeyValue           PLS_INTEGER := 0;               -- random number between StartValue and MaxValue

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

   v_GreaterThan32k     EXCEPTION;
   v_GreaterThan1k      EXCEPTION;

BEGIN
	-- since we can't write more then 32k at once, any value of LobSize greater than 32k is not allowed
        IF (LobSize > 32767) THEN
           RAISE v_GreaterThan32k;
        END IF;

        v_LobReadBuf := UTL_RAW.CAST_TO_RAW(RPAD('0',  32767, '0'));

	v_KeyStartValue := UserNum*v_USERKEYRANGE;
	v_KeyMaxValue := (v_KeyStartValue-1) + (NumRows*Iter);

        dbms_random.initialize(LobSize);

     	FOR q IN 1..Iter LOOP

           IF q = 2 THEN                                -- discard q=1 as warmup
             v_StartTimeTot := dbms_utility.get_time();
             v_StartCpuTot := dbms_utility.get_cpu_time();
           END IF;

	   v_StartTime := dbms_utility.get_time();
           FOR j IN 1..NumRows LOOP
	       v_KeyValue := dbms_random.value(v_KeyStartValue, v_KeyMaxValue);
	       SELECT DOCUMENT INTO v_LobReadBuf FROM FOO WHERE PKEY = v_KeyValue;
           END LOOP;	-- End of NumRows 'FOR' loop

	   v_EndTime := dbms_utility.get_time();

	   v_ElapsedTime := (v_EndTime-v_StartTime)*10;
           dbms_output.put_line ('Elapsed time for Iter '|| q || ' Selected ('||NumRows||') in msecs: '||v_ElapsedTime); 
	    
        END LOOP; -- End of Iter 'FOR' loop

	v_EndTimeTot := dbms_utility.get_time();
        v_EndCpuTot := dbms_utility.get_cpu_time();

        v_ElapsedTimeTot := (v_EndTimeTot-v_StartTimeTot)*10;
        v_ElapsedCpuTot := (v_EndCpuTot-v_StartCpuTot)*10;

        dbms_output.put_line ('------------------------------------------------------------------');
        dbms_output.put_line ('Total Elapsed time for select of ('||NumRows*(Iter-1)||' rows) in msecs (excluding Iter 1): '||v_ElapsedTimeTot );

	IF Iter > 1 THEN
          v_AvgElapsed := round(v_ElapsedTimeTot/(Iter-1),2);
          v_AvgCpu := round(v_ElapsedCpuTot/(Iter-1),2);
          v_AvgRate := round((LobSize*NumRows*1000)/(v_AvgElapsed*1024*1024),2);

          dbms_output.put_line ('Avg Elapsed time for a Iter ('||NumRows||' rows) in msecs (excluding Iter 1): '||v_AvgElapsed );
          dbms_output.put_line ('Avg CPU time for a Iter ('||NumRows||' rows) in msecs (excluding Iter 1): '||v_AvgCpu );
          dbms_output.put_line ('Avg Read Rate for ('||NumRows||' rows)  (excluding Iter 1) : '||v_AvgRate ||' (Mb/sec)' );

        END IF;

        Select securefile into v_LobType from user_lobs where table_name='FOO' and column_name='DOCUMENT';

        IF v_LobType = 'YES' THEN
           dbms_output.put_line ('SECUREFILE Lob Read Test Finished (Using PLSQL Data API) ');
        ELSE
           dbms_output.put_line ('BASICFILE Lob Read Test Finished (Using PLSQL Data API) ');
        END IF;
        dbms_output.put_line ('Selected LobSize='||LobSize||' bytes NumRows or CommitSize='||NumRows ||' Iter='||Iter );
        dbms_output.put_line ('------------------------------------------------------------------');
        dbms_output.put_line ('       ');

EXCEPTION	
	WHEN v_GreaterThan32k THEN
	    dbms_output.put_line('Input Parameter ERROR ');
	    dbms_output.put_line('LobSize value of more than 32767 is not allowed..');
END;
/
show errors

