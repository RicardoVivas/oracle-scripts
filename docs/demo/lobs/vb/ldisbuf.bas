' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/ldisbuf.bas

'Disabling LOB buffering (persistent LOBs)
Dim MySession As OraSession
Dim OraDb As OraDatabase
Dim OraDyn As OraDynaset, OraAdPhoto1 As OraBlob, OraAdPhotoClone As OraBlob

Set MySession = CreateObject("OracleInProcServer.XOraSession")
Set OraDb = MySession.OpenDatabase("exampledb", "samp/samp", 0&)
Set OraDyn = OraDb.CreateDynaset(
   "SELECT * FROM Print_media ORDER BY product_id, ad_id", ORADYN_DEFAULT)

Set OraAdPhoto1 = OraDyn.Fields("ad_photo").Value
'Disable buffering: 
OraAdPhoto1.DisableBuffering
