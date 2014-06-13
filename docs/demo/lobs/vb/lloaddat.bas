' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/lloaddat.bas

Dim OraDyn as OraDynaset, OraPhoto1 as OraBLOB, OraMyBfile as OraBFile

OraConnection.BeginTrans
Set OraDyn = OraDb.CreateDynaset(
   "SELECT * FROM Print_media ORDER BY product_id, ad_id", ORADYN_DEFAULT)
Set OraPhoto1 = OraDyn.Fields("ad_photo").Value

OraDb.Parameters.Add "id", 3060,ORAPARAM_INPUT
OraDb.Parameters.Add "mybfile", Null,ORAPARAM_OUTPUT
OraDb.Parameters("mybfile").serverType = ORATYPE_BFILE

OraDb.ExecuteSQL ("begin  GetBFile(:id, :mybfile); end;")

Set OraMyBFile = OraDb.Parameters("mybfile").Value
'Go to Next row
OraDyn.MoveNext

OraDyn.Edit
'Lets update OraPhoto1 data with that from the BFILE
OraPhoto1.CopyFromBFile  OraMyBFile
OraDyn.Update

OraConnection.CommitTrans
