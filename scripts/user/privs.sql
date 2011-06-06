CLEAR
SELECT * from dba_tab_privs  where grantee = '&&USR_OR_ROLE';
SELECT * FROM dba_role_privs where grantee = '&&USR_OR_ROLE';
SELECT * FROM dba_sys_privs  WHERE grantee = '&&USR_OR_ROLE';