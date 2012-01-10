clear

undefine USR_OR_ROLE

rem  describes the object grants for which the current user is the object owner, grantor, or grantee.
SELECT * from dba_tab_privs  where grantee = '&&USR_OR_ROLE' ORDER BY GRANTEE;

rem DBA_SYS_PRIVS describes system privileges granted to users and roles
SELECT * FROM dba_sys_privs  WHERE grantee = '&&USR_OR_ROLE' ORDER BY GRANTEE;

rem DBA_ROLE_PRIVS describes the roles granted to all users and roles in the database.
SELECT * FROM DBA_ROLE_PRIVS where grantee = '&&USR_OR_ROLE' ORDER BY GRANTEE;


rem ROLE_TAB_PRIVS describes table privileges granted to roles. 
rem Information is provided only about roles to which the user has access.
SELECT * FROM ROLE_TAB_PRIVS WHERE ROLE = '&&USR_OR_ROLE' ORDER BY ROLE;

rem ROLE_SYS_PRIVS describes system privileges granted to roles. 
rem Information is provided only about roles to which the user has access.
SELECT * FROM ROLE_SYS_PRIVS WHERE ROLE = '&&USR_OR_ROLE' ORDER BY ROLE;



#If only SELECT_CATALOG_ROLE is enabled then it provides access to all SYS views only.
#If only SELECT ANY DICTIONARY privilege is enabled then it provides access to SYS schema objects only.
