Rem
Rem $Header: LocatorAPI_Insert.sql 22-mar-2007.13:39:43 vdjegara Exp $
Rem
Rem LocatorAPI_Insert.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      LocatorAPI_Insert.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vdjegara    01/29/07 - Locator Interface Insert test
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


CREATE OR REPLACE PROCEDURE LocatorAPI_Insert (LobSize NUMBER, NumRows NUMBER, Iter NUMBER, UserNum NUMBER) as
   TYPE KeysWriteBuf_Varr   IS VARRAY(1000) OF NUMBER ;	-- keep 1000 as maximum commit batch size

   v_KeysWriteBuf  	KeysWriteBuf_Varr   := KeysWriteBuf_Varr(NULL); 

   v_LobLocator  	BLOB;

   v_MaxAmt    		PLS_INTEGER := 32767;		-- maximum allowed in plsql
   v_AmtToWrite		PLS_INTEGER ;
   v_Offset		PLS_INTEGER := 1;
   v_KeyStartValue	PLS_INTEGER := 0;
   v_NextKeyStart	PLS_INTEGER := 0;
   v_USERKEYRANGE	PLS_INTEGER := 100000;	
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

   v_GreaterThan1k      EXCEPTION;
 
   v_LobInputFile 	BFILE := BFILENAME('FILEDIR', 'DocumentFile.dat');

BEGIN
	-- for commit batch greater than 1000, increase varray size
	IF (NumRows > 1000) THEN
          RAISE v_GreaterThan1k;
        END IF;

	-- Open DocumentFile.dat 
	DBMS_LOB.FILEOPEN (v_LobInputFile, DBMS_LOB.FILE_READONLY);

  	v_KeyStartValue := UserNum*v_USERKEYRANGE;
	
	FOR i IN 1..NumRows LOOP
	  v_KeysWriteBuf.EXTEND;
	  v_KeysWriteBuf(i) := (i-1)+v_KeyStartValue;
	END LOOP;


	-- Insert BLOB data now, using Lob locator 	
     	FOR q IN 1..Iter LOOP

	   IF q = 2 THEN				-- discard q=1 as warmup 
	     v_StartTimeTot := dbms_utility.get_time();
	     v_StartCpuTot := dbms_utility.get_cpu_time();
	   END IF;

	   v_StartTime := dbms_utility.get_time(); 
           FOR j IN 1..NumRows LOOP
	       INSERT INTO FOO VALUES (v_KeysWriteBuf(j), empty_blob());
               SELECT DOCUMENT INTO v_LobLocator FROM FOO WHERE PKEY = v_KeysWriteBuf(j) FOR UPDATE;
	       DBMS_LOB.LOADFROMFILE(v_LobLocator, v_LobInputFile, LobSize);

           END LOOP;	-- End of NumRows 'FOR' loop
           COMMIT;

	   v_EndTime := dbms_utility.get_time();
	   -- convert to msec by x10, not accurate, but doing for consistency with OCI demo programs
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
          dbms_output.put_line ('Avg Write Rate for ('||NumRows||' rows)  (excluding Iter 1) : '||v_AvgRate  ||' (Mb/sec)' );

	END IF;
 
	Select securefile into v_LobType from user_lobs where table_name='FOO' and column_name='DOCUMENT';

	IF v_LobType = 'YES' THEN
           dbms_output.put_line ('SECUREFILE Lob Write Test Finished (Using DBMS_LOB.LOADFROMFILE API) ');
	ELSE
           dbms_output.put_line ('BASICFILE Lob Write Test Finished (Using DBMS_LOB.LOADFROMFILE API) ');
	END IF; 
        dbms_output.put_line ('Inserted LobSize='||LobSize||' bytes NumRows or CommitSize='||NumRows ||' Iter='||Iter );
	dbms_output.put_line ('------------------------------------------------------------------');
	dbms_output.put_line ('       ');

EXCEPTION
        WHEN v_GreaterThan1k THEN
            dbms_output.put_line('Input Parameter ERROR ');
            dbms_output.put_line('For NumRows greater than 1000, increase v_KeysWriteBuf varray size..');
END;
/
show errors

