

-- Restrict Access
startup restrict
alter system enable/disable restricted session

system privilege: restricted session


-- For some shutdown immediate does not work, try this:
shutdown abort;
startup restrict;
shutdown immediate;
