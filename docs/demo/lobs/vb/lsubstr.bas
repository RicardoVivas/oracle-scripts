' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/lsubstr.bas

'Reading portion of a LOB (or BFILE). In OO4O this is accomplished by 
'setting the OraBlob.Offset and OraBlob.chunksize properties.
'Using the OraClob.Read mechanism
Dim MySession As OraSession
Dim OraDb As OraDatabase
Dim OraDyn as OraDynaset, OraAdSourceText as OraClob, amount_read%, chunksize%, 
chunk

Set MySession = CreateObject("OracleInProcServer.XOraSession")
Set OraDb = MySession.OpenDatabase("exampledb", "samp/samp", 0&)

Set OraDyn = OraDb.CreateDynaset("SELECT * FROM Print_media", ORADYN_DEFAULT)
Set OraAdSourceText = OraDyn.Fields("ad_sourcetext").Value

'Let's read 100 bytes from the 500th byte onwards: 
OraAdSourceText.Offset = 500
OraAdSourceText.PollingAmount = OraAdSourceText.Size 'Read entire CLOB contents
amount_read = OraAdSourceText.Read(chunk, 100) 
'chunk returned is a variant of type byte array
