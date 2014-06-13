' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/lcopyloc.bas

'Copying a LOB locator
Dim MySession As OraSession
Dim OraDb As OraDatabase
Dim OraDyn As OraDynaset, OraAdPhoto1 As OraBlob, OraAdPhotoClone As OraBlob

Set MySession = CreateObject("OracleInProcServer.XOraSession")
Set OraDb = MySession.OpenDatabase("exampledb", "samp/samp", 0&)
Set OraDyn = OraDb.CreateDynaset(
   "SELECT * FROM Print_media ORDER BY product_id, ad_id ", ORADYN_DEFAULT)
Set OraAdPhoto1 = OraDyn.Fields("ad_photo").Value
Set OraAdPhotoClone = OraAdPhoto1.Clone
 
OraDyn.MoveNext
 
'Copy 1000 bytes of LOB values OraAdPhotoClone to OraAdPhotol at OraAdPhotol
'offset 100: 
OraDyn.Edit
OraAdPhoto1.Copy OraAdPhotoClone, 1000, 100
OraDyn.Update
