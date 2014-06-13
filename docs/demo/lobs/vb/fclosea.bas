' This file is installed in the following path when you install
' the database: $ORACLE_HOME/rdbms/demo/lobs/vb/fclosea.bas

'Closing all open BFILEs. 

Dim OraParameters as OraParameters, OraAdGraphic as OraBFile 
OraConnection.BeginTrans 
 
Set OraParameters = OraDatabase.Parameters 
 
'Define in out parameter of BFILE type: 
OraParameters.Add "MyAdGraphic", Null,ORAPARAM_BOTH,ORATYPE_BFILE 
 
'Select the ad graphic BFile for product_id 2268: 
OraDatabase.ExecuteSQL("Begin SELECT ad_graphic INTO :MyAdGraphic FROM 
Print_media WHERE product_id = 2268 AND ad_id = 21001; END; " )  
 
'Get the BFile ad_graphic column: 
set OraAdGraphic = OraParameters("MyAdGraphic").Value 
 
'Open the OraAdGraphic: 
OraAdGraphic.Open 
 
'Do some processing on OraAdGraphic 
 
'Close all the BFILEs associated with OraAdGraphic: 
OraAdGraphic.CloseAll 
