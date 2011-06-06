alter table T nologging;  (to make the table be nologging)
alter table T move tablespace b;
alter table T logging;    (to put it back)

the indexes will become unusable. rebuild it!!