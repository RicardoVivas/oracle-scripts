' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/fupdate.bas

'Updating a BFILE by initializing a BFILE locator. 

Dim MySession As OraSession
Dim OraDb As OraDatabase
Dim OraParameters As OraParameters, OraAdGraphic As OraBfile

Set MySession = CreateObject("OracleInProcServer.XOraSession")
Set OraDb = MySession.OpenDatabase("pmschema", "pm/pm", 0&)

OraDb.Connection.BeginTrans

Set OraParameters = OraDb.Parameters

'Define in out parameter of BFILE type: 
OraParameters.Add "MyAdGraphic", Null, ORAPARM_BOTH, ORATYPE_BFILE

'Define out parameter of BFILE type: 
OraDb.ExecuteSQL (
"BEGIN SELECT ad_graphic INTO :MyAdGraphic FROM Print_media 
     WHERE product_id = 2056 AND ad_id = 12001; 
      END;")
       
'Update the ad_graphic BFile for product_id=2056 AND ad_id = 12001 
      to product_id=2268 AND ad_id = 21001: 
OraDb.ExecuteSQL (
   "UPDATE Print_media SET ad_graphic = :MyAdGraphic 
      WHERE product_id = 2268 AND ad_id = 21001")

'Get Directory alias and filename
'MsgBox " Directory alias is " & OraAdGraphic1.DirectoryName & " Filename is " & OraAdGraphic1.filename

OraDb.Connection.CommitTrans
