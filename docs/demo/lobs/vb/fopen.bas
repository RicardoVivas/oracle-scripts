' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/fopen.bas

'Opening a BFILE using OPEN.
Dim OraDyn as OraDynaset, OraAdGraphic as OraBFile
Set OraDyn = OraDb.CreateDynaset("select * from Print_media",ORADYN_DEFAULT) 
Set OraAdGraphic = OraDyn.Fields("ad_graphic").Value
 
'Go to the last row and open the Bfile for reading: 
OraDyn.MoveLast 
OraAdGraphic.Open 'Open Bfile for reading 
'Do some processing:  
OraAdGraphic.Close 
