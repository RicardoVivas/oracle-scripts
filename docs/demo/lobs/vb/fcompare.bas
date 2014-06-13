' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/fcompare.bas

'Comparing all or parts of two BFILES. 
'The PL/SQL packages and the tables mentioned here are not part of the
'standard OO4O installation: 

Dim MySession As OraSession
Dim OraDb As OraDatabase
Dim OraDyn As OraDynaset, OraAdGraphic As OraBfile, OraMyAdGraphic As OraBfile, OraSql As OraSqlStmt

Set MySession = CreateObject("OracleInProcServer.XOraSession")
Set OraDb = MySession.OpenDatabase("pmschema", "pm/pm", 0&)

OraDb.Connection.BeginTrans

Set OraParameters = OraDb.Parameters

OraParameters.Add "id", 3106, ORAPARM_INPUT

'Define out parameter of BFILE type: 
OraParameters.Add "MyAdGraphic", Null, ORAPARM_OUTPUT
OraParameters("MyAdGraphic").ServerType = ORATYPE_BFILE

Set OraSql = 
   OraDb.CreateSql(
      "BEGIN SELECT ad_graphic INTO :MyAdGraphic FROM Print_media WHERE product_id = :id; 
         END;", ORASQL_FAILEXEC)

Set OraMyAdGraphic = OraParameters("MyAdGraphic").Value

'Create dynaset: 
Set OraDyn = 
   OraDb.CreateDynaset(
      "SELECT * FROM Print_media WHERE product_id = 3106", ORADYN_DEFAULT)
Set OraAdGraphic = OraDyn.Fields("ad_graphic").Value

'Open the Bfile for reading: 
OraAdGraphic.Open
OraMyAdGraphic.Open

If OraAdGraphic.Compare(OraMyAdGraphic) Then
    'Process the data
Else
   'Do error processing
End If
OraDb.Connection.CommitTrans
