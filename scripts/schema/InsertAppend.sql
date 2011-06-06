
--- If you want to reduce time and space you can do direct loads so :

Insert /*+ APPEND */ into joelperez nologging values ( 'Friend0', 10);
 

ALTER TABLE employees MODIFY LOB (resume) (CACHE); 

