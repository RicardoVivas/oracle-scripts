' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/lwrite.bas

'Writing data to a LOB
'There are two ways of writing a lob, with orablob.write or 
orablob.copyfromfile

'Using the OraBlob.Write mechanism
Dim OraDyn As OraDynaset, OraAdPhoto As OraBlob, amount_written%, chunksize%, 
curchunk() As Byte

chunksize = 32767
Set OraDyn = OraDb.CreateDynaset("SELECT * FROM Print_media", ORADYN_DEFAULT)
Set OraAdPhoto = OraDyn.Fields("ad_photo").Value

fnum = FreeFile
Open "c:\tmp\keyboard_3106_13001" For Binary As #fnum

OraAdPhoto.offset = 1
OraAdPhoto.pollingAmount = LOF(fnum)
remainder = LOF(fnum)

Dim piece As Byte
Get #fnum, , curchunk
 
OraDyn.Edit
  
piece = ORALOB_FIRST_PIECE
OraAdPhoto.Write curchunk, chunksize, ORALOB_FIRST_PIECE
 
While OraAdPhoto.Status = ORALOB_NEED_DATA
   remainder = remainder - chunksize
   If remainder  <= chunksize Then
      chunksize = remainder
      piece = ORALOB_LAST_PIECE
   Else
      piece = ORALOB_NEXT_PIECE
   End If
    
   Get #fnum, , curchunk
   OraAdPhoto.Write curchunk, chunksize, piece
    
Wend

OraDyn.Update

'Using the OraBlob.CopyFromFile mechanism

Set OraDyn = OraDb.CreateDynaset("select * from Print_media", ORADYN_DEFAULT)
Set OraAdPhoto = OraDyn.Fields("ad_photo").Value

Oradyn.Edit
OraAdPhoto.CopyFromFile "c:\keyboardphoto3106.jpg"
Oradyn.Update
