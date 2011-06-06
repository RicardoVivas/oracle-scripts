select username, password from dba_users;
--shows:       dip CE4A36B8E06CA59C
 
-- you can change the password dip , do sth, then change back using
 alter user dip identified by values 'CE4A36B8E06CA59C';
