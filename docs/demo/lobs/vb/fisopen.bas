' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/fisopen.bas

' Checking if the BFILE is open with ISOPEN
Dim OraDyn as OraDynaset, OraAdGraphic as OraBFile, amount_read%, chunksize%, chunk 
 
chunksize = 32767
Set OraDyn = OraDb.CreateDynaset("select * from Print_media", ORADYN_DEFAULT) 
Set OraAdGraphic = OraDyn.Fields("ad_graphic").Value 
 
If OraAdGraphic.IsOpen then 
  'Process, if the file is already open: 
Else 
   'Process, if the file is not open, and return an error: 
End If 

