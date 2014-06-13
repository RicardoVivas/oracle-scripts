' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/finsert.bas

' Inserting a row containing a BFILE by initializing a BFILE.

Dim OraDyn as OraDynaset, OraPhoto as OraBFile, OraMusic as OraBFile 
Set OraDyn = OraDb.CreateDynaset("select * from Print_media", ORADYN_DEFAULT) 
Set OraMusic = OraDyn.Fields("ad_graphic").Value
 
'Edit the first row and initiliaze the "ad_graphic" column: 
OraDyn.Edit 
OraPhoto.DirectoryName = "ADGRAPHIC_DIR" 
OraPhoto.Filename = "mousepad_graphic_2056_12001" 
OraDyn.Update
