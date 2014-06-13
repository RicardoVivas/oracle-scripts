' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/lcompare.bas

'Comparing all or part of two LOBs
Dim MySession As OraSession
Dim OraDb As OraDatabase

Set MySession = CreateObject("OracleInProcServer.XOraSession")
Set OraDb = MySession.OpenDatabase("exampledb", "samp/samp", 0&)
Dim OraDyn as OraDynaset, OraAdPhoto1 as OraBLOB, OraAdPhotoClone as OraBLOB

Set OraDyn = OraDb.CreateDynaset(
   "SELECT * FROM Print_media ORDER BY product_id, ad_id", ORADYN_DEFAULT)
Set OraAdPhoto1 = OraDyn.Fields("ad_photo").Value
'Clone it for future reference
Set OraAdPhotoClone = OraAdPhoto1.Clone

'Lets go to the next row and compare LOBs
OraDyn.MoveNext

MsgBox CBool(OraAdPhotot1.Compare(OraAdPhototClone, OraAdPhotoClone.size, 1, 1))
