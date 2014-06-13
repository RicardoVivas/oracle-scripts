' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/ldisplay.bas

'Displaying LOB data
'Using the OraClob.Read mechanism
Dim MySession As OraSession
Dim OraDb As OraDatabase

Set MySession = CreateObject("OracleInProcServer.XOraSession")
Set OraDb = MySession.OpenDatabase("exampledb", "samp/samp", 0&)
Dim OraDyn as OraDynaset, OraAdSourceText as OraClob, amount_read%, chunksize%, 
chunk
chunksize = 32767
Set OraDyn = OraDb.CreateDynaset("SELECT * FROM Print_media", ORADYN_DEFAULT)
Set OraAdSourceText = OraDyn.Fields("ad_sourcetext").Value
OraAdSourceText.PollingAmount = OraAdSourceText.Size 'Read entire CLOB contents
Do
   'chunk returned is a variant of type byte array: 
    amount_read = OraAdSourceText.Read(chunk, chunksize) 
   'Msgbox chnunk
Loop Until OraAdSourceText.Status <> ORALOB_NEED_DATA
