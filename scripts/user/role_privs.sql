clear

rem ROLE_SYS_PRIVS describes system privileges granted to roles. Information is provided only about roles to which the user has access.
SELECT * FROM ROLE_SYS_PRIVS WHERE ROLE = '&ROLE';
SELECT * FROM ROLE_TAB_PRIVS WHERE ROLE = '&ROLE';

rem DBA_ROLE_PRIVS describes the roles granted to all users and roles in the database.
SELECT * FROM DBA_ROLE_PRIVS ORDER BY GRANTEE