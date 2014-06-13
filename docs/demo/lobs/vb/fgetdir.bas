' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/fgetdir.bas

'Getting the directory alias and filename 
'The PL/SQL packages and tables mentioned here are not part of the
'standard OO4O installation:

Dim MySession As OraSession
Dim OraDb As OraDatabase
Dim OraAdGraphic1 As OraBfile, OraSql As OraSqlStmt

Set MySession = CreateObject("OracleInProcServer.XOraSession")
Set OraDb = MySession.OpenDatabase("pmschema", "pm/pm", 0&)
OraDb.Connection.BeginTrans
Set OraParameters = OraDb.Parameters
OraParameters.Add "id", 2056, ORAPARM_INPUT

'Define out parameter of BFILE type:
OraParameters.Add "MyAdGraphic", Null, ORAPARM_OUTPUT
OraParameters("MyAdGraphic").ServerType = ORATYPE_BFILE

Set OraSql = 
   OraDb.CreateSql(
      "BEGIN SELECT ad_graphic INTO :MyAdGraphic FROM Print_media 
         WHERE product_id = :id; 
         END;", ORASQL_FAILEXEC)

Set OraAdGraphic1 = OraParameters("MyAdGraphic").Value
'Get Directory alias and filename: 
MsgBox " Directory alias is " & OraAdGraphic1.DirectoryName & 
   " Filename is " & OraAdGraphic1.filename

OraDb.Connection.CommitTrans
