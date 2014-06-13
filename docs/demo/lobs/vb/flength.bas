' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/flength.bas

'Getting the length of a BFILE. 
'The PL/SQL packages and the tables mentioned here are not part of the ' 'standard OO4O installation: 

Dim MySession As OraSession
Dim OraDb As OraDatabase

Set MySession = CreateObject("OracleInProcServer.XOraSession")
Set OraDb = MySession.OpenDatabase("pmschema", "pm/pm", 0&)

OraDb.Connection.BeginTrans

Set OraParameters = OraDb.Parameters

OraParameters.Add "id", 2056, ORAPARM_INPUT

'Define out parameter of BFILE type: 
OraParameters.Add "AdGraphic", Null, ORAPARM_OUTPUT
OraParameters("MyAdGraphic").ServerType = ORATYPE_BFILE

Set OraSql = 
   OraDb.CreateSql(
      "BEGIN SELECT ad_graphic INTO :MyAdGraphic FROM Print_media WHERE product_id = :id; 
         END;", ORASQL_FAILEXEC)

Set OraAdGraphic = OraParameters("MyAdGraphic").Value

If OraAdGraphic.Size = 0 Then
    MsgBox "BFile size is 0"
Else
    MsgBox "BFile size is " & OraAdGraphic.Size
End If
OraDb.Connection.CommitTrans
