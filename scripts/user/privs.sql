clear

undefine USR_OR_ROLE

rem  What object privileges does user/role have?
SELECT * from dba_tab_privs  where grantee = '&&USR_OR_ROLE' ORDER BY GRANTEE;

rem What system privileges does user/role have?
SELECT * FROM dba_sys_privs  WHERE grantee = '&&USR_OR_ROLE' ORDER BY GRANTEE;

rem What roles priviledge does user/role have?
SELECT * FROM DBA_ROLE_PRIVS where grantee = '&&USR_OR_ROLE' ORDER BY GRANTEE;


rem Information is provided only about roles to which the user has access.
SELECT * FROM ROLE_TAB_PRIVS WHERE ROLE = '&&USR_OR_ROLE' ORDER BY ROLE;

rem Describes system privileges granted to roles. Information is provided only about roles to which the user has access.
SELECT * FROM ROLE_SYS_PRIVS WHERE ROLE = '&&USR_OR_ROLE' ORDER BY ROLE;