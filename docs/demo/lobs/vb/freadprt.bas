' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/freadprt.bas

' Reading portion of a BFILE data using substr.
Dim MySession As OraSession
Dim OraDb As OraDatabase

Dim OraDyn As OraDynaset, OraAdGraphic As OraBfile, amount_read%, chunksize%, chunk

Set MySession = CreateObject("OracleInProcServer.XOraSession")
Set OraDb = MySession.OpenDatabase("pmschema", "pm/pm", 0&)

chunk_size = 32767
Set OraDyn = OraDb.CreateDynaset("select * from Print_media", ORADYN_DEFAULT)
Set OraAdGraphic = OraDyn.Fields("ad_graphic").Value
OraMusic.PollingAmount = OraAdGraphic.Size 'Read entire BFILE contents
OraAdGraphic.offset = 255 'Read from the 255th position
'Open the Bfile for reading: 
OraAdGraphic.Open
amount_read = OraAdGraphic.Read(chunk, chunk_size) 'chunk returned is a variant of type byte array
 If amount_read <> chunk_size Then
    'Do error processing
 Else
     'Process the data
 End If
