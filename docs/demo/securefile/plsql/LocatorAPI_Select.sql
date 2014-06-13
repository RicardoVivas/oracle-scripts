Rem
Rem $Header: LocatorAPI_Select.sql 22-mar-2007.13:39:44 vdjegara Exp $
Rem
Rem LocatorAPI_Select.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      LocatorAPI_Select.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vdjegara    01/29/07 - Locator Interface Select test
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

CREATE OR REPLACE PROCEDURE LocatorAPI_Select (LobSize NUMBER, NumRows NUMBER, Iter NUMBER, UserNum NUMBER) as

   v_LobReadBuf    	RAW(32767);	
   v_LobLocator 	BLOB;

   v_USERKEYRANGE	PLS_INTEGER := 100000;	
   v_KeyStartValue	PLS_INTEGER := 0;		-- derived from USERKEYRANGE * UserNum
   v_KeyMaxValue	PLS_INTEGER := 0;		-- derived from StartValue + NumRows*Iter
   v_KeyValue  		PLS_INTEGER := 0;		-- random number between StartValue and MaxValue
   
   v_ReadSize   	PLS_INTEGER := 32528;		-- it is a multiple of chunksize (8132x4, 16264x2 etc) 
   v_AmtToRead		PLS_INTEGER ;
   v_Offset		PLS_INTEGER := 1;
   v_LobType		VARCHAR2(3); 

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

BEGIN

	-- Initialize Lob read buffer to 00000...
        v_LobReadBuf := UTL_RAW.CAST_TO_RAW(RPAD('0', 32767, '0'));

  	v_KeyStartValue := UserNum*v_USERKEYRANGE;
	v_KeyMaxValue := (v_KeyStartValue-1) + (NumRows*Iter);
	
	dbms_random.initialize(LobSize);
	

     	FOR q IN 1..Iter LOOP

	   IF  q = 2 THEN
	    v_StartTimeTot := dbms_utility.get_time();
	    v_StartCpuTot := dbms_utility.get_cpu_time();
	   END IF;
 
	   v_StartTime := dbms_utility.get_time();
           FOR j IN 1..NumRows LOOP
	       v_KeyValue := dbms_random.value(v_KeyStartValue, v_KeyMaxValue);
	       v_Offset := 1;
	       v_AmtToRead := 0;

               SELECT DOCUMENT INTO v_LobLocator FROM FOO WHERE PKEY = v_KeyValue ;
	       v_AmtToRead := DBMS_LOB.GETLENGTH(v_LobLocator);
 
	       -- Read 32528 bytes at a time 
	       WHILE v_AmtToRead >= v_ReadSize LOOP
                    DBMS_LOB.READ(v_LobLocator, v_ReadSize, v_Offset, v_LobReadBuf );

		    v_Offset := v_Offset + v_ReadSize;
		    v_AmtToRead := v_AmtToRead - v_ReadSize;
	       END LOOP;

	       -- Last portion of the Read (anything less than v_ReadSize bytes) 
	       IF v_AmtToRead > 0 THEN
           	    DBMS_LOB.READ(v_LobLocator, v_AmtToRead, v_Offset, v_LobReadBuf );
	       END IF;

           END LOOP;	-- End of NumRows 'FOR' loop

	   v_EndTime := dbms_utility.get_time();
	   -- convert to msec by x10
	   v_ElapsedTime := (v_EndTime-v_StartTime)*10;

           dbms_output.put_line ('Elapsed time for Iter '|| q || ' Selected ('||NumRows|| ' rows) in msecs: '||v_ElapsedTime); 
	    
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
          dbms_output.put_line ('Avg Read Rate for ('||NumRows||' rows)  (excluding Iter 1) : '||v_AvgRate  ||' (Mb/sec)' );

        END IF;

        Select securefile into v_LobType from user_lobs where table_name='FOO' and column_name='DOCUMENT';

        IF v_LobType = 'YES' THEN
           dbms_output.put_line ('SECUREFILE Lob Read Test Finished (Using DBMS_LOB.READ API) ');
        ELSE
           dbms_output.put_line ('BASICFILE Lob Read Test Finished (Using DBMS_LOB.READ API) ');
        END IF;
        dbms_output.put_line ('Selected LobSize='||LobSize ||' bytes NumRows='||NumRows ||' Iter='||Iter );
        dbms_output.put_line ('------------------------------------------------------------------');
        dbms_output.put_line ('       ');

END;
/
show errors

