Ok a follow up to yesterdays post, Jari Kuhanen my regular sparing partner for discussing Oracle features and techniques 
came up with the fastest solution yet ...

1. Do a CTAS using CAST to change the column type, using nologging and parallel.
2. Drop the old table.
3. Rename the new table.
4. Recreate the PK index, using parallel nologging.

SQL> CREATE TABLE NEW_ANDY
NOLOGGING PARALLEL 4
AS
SELECT
...
CAST( RECEIPT_LINE AS NUMBER(16) ) RECEIPT_LINE,
...
FROM andy