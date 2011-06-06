
The following is quite useful is you do not know the password of sysman

$ sqlplus SYS/sys_password AS SYSDBA

After you connect as the SYS user, alter the session to run as SYSMAN:
SQL> ALTER SESSION SET current_schema = SYSMAN;


