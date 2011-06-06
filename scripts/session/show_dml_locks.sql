rem - HS note: this sql can be achieved by view "instance locks -> User Locks" in GC
rem
rem -------------------------------------------------------------------------
rem  Shows actual DML-Locks (incl. Table-Name)
rem  WAIT = YES are users waiting for a lock
rem -----------------------------------------------------------------------
rem
--
SET PAGES 24 LINES 200 FEED ON ECHO OFF TERMOUT ON HEAD ON
COLUMN PROGRAM FORMAT A80 TRUNC
COLUMN LOCKER FORMAT A10 TRUNC
COLUMN T_OWNER FORMAT A10 TRUNC
COLUMN OBJECT_NAME FORMAT A25 TRUNC
COLUMN WAIT FORMAT A4
TTITLE "Actual DML-Locks (TM+TX)"

--
    select  /*+ rule */
        decode(L.REQUEST,0,'NO','YES') WAIT,
        S.OSUSER,
        S.PROCESS,
        S.USERNAME LOCKER,
        U.NAME T_OWNER,
        O.NAME OBJECT_NAME,
        '  '||S.PROGRAM PROGRAM
    from    V$LOCK L,
            V$SESSION S,
            OBJ$ O,
            USER$ U
    where   U.USER# = O.OWNER#
    and     S.SID = L.SID
    and     L.ID1 = O.OBJ#
    and     L.TYPE = 'TM'
     union
    select  decode(L.REQUEST,0,'NO','YES') WAIT,
        S.OSUSER,
        S.PROCESS,
        S.USERNAME LOCKER,
        '-',
        'Record(s)',
        '  '||S.PROGRAM PROGRAM
    from    V$LOCK L,
            V$SESSION S
    where   S.SID = L.SID
    and     L.TYPE = 'TX'
    order by 7,5,1,2,6
/

ttitle off
col program clear
col locker clear
col t_owner clear
col object_name clear
col wait clear
