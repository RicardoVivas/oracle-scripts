' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/floadlob.bas

'Loading a LOB with BFILE data 

Dim OraDyn as OraDynaset, OraDyn2 as OraDynaset, OraAdGraphic as OraBFile 
Dim OraAdPhoto as OraBlob

chunksize = 32767
Set OraDyn = OraDb.CreateDynaset("select * from Print_media", ORADYN_DEFAULT)

Set OraAdGraphic = OraDyn.Fields("ad_graphic").Value
Set OraAdPhoto = OraDyn.Fields("ad_photo").Value

OraDyn.Edit
'Load LOB with data from BFILE: 
OraAdPhoto.CopyFromBFile (OraAdGraphic)
OraDyn.Update
