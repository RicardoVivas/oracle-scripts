-- -------------------------------------------------------------------------
-- - HS note: this sql can be achieved by view "instance locks -> User Locks" in GC
--
--  Run as sysdba
--  Shows actual DML-Locks (incl. Table-Name)
--  WAIT = YES are users waiting for a lock
-- -----------------------------------------------------------------------

    select   
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

 