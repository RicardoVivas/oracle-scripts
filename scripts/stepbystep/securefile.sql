drop table securefile_tab purge;

CREATE TABLE securefile_tab (
  id         NUMBER,
  clob_data  CLOB
) 
LOB(clob_data) STORE AS SECUREFILE securefile_lob(
 encrypt
 compress
);

INSERT INTO securefile_tab VALUES (1, 'ONE');
INSERT INTO securefile_tab VALUES (2, 'TWO');
COMMIT;

SET SERVEROUTPUT ON
DECLARE
  l_clob  CLOB;
BEGIN
  SELECT clob_data
  INTO   l_clob
  FROM   securefile_tab
  WHERE  id = 1
  FOR UPDATE;

  DBMS_OUTPUT.put_line('Compression  : ' || DBMS_LOB.getoptions(l_clob, DBMS_LOB.opt_compress));
  DBMS_OUTPUT.put_line('Encryption   : ' || DBMS_LOB.getoptions(l_clob, DBMS_LOB.opt_encrypt));
  DBMS_OUTPUT.put_line('Deduplication: ' || DBMS_LOB.getoptions(l_clob, DBMS_LOB.opt_deduplicate));

  ROLLBACK;
END;
/