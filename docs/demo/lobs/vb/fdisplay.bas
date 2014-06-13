' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/fdisplay.bas

' Displaying BFILE data.  
Dim MySession As OraSession
Dim OraDb As OraDatabase

Dim OraDyn As OraDynaset, OraAdGraphio As OraBfile, amount_read%, chunksize%, chunk As Variant

Set MySession = CreateObject("OracleInProcServer.XOraSession")
Set OraDb = MySession.OpenDatabase("pmschema", "pm/pm", 0&)

chunksize = 32767
Set OraDyn = OraDb.CreateDynaset("select * from Print_media", ORADYN_DEFAULT)
Set OraAdGraphic = OraDyn.Fields("ad_graphic").Value

OraAdGraphic.offset = 1
OraAdGraphic.PollingAmount = OraAdGraphic.Size 'Read entire BFILE contents

'Open the Bfile for reading: 
OraAdGraphic.Open
amount_read = OraAdGraphic.Read(chunk, chunksize)

While OraAdGraphic.Status = ORALOB_NEED_DATA
    amount_read = OraAdGraphic.Read(chunk, chunksize)
Wend
OraAdGraphic.Close
