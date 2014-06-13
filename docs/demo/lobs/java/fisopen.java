/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/fisopen.java */

/* Checking if the BFILE is open after using the openFile API and after
 * using DBMS_LOB.FILEOPEN.
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver fisopen
*/

import java.sql.Connection;
import java.sql.Statement;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.BFILE;
import oracle.jdbc.OracleTypes;
import oracle.jdbc.OracleResultSet;
import oracle.jdbc.OracleCallableStatement;

public class fisopen
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery (
      "SELECT BFILENAME('MEDIA_DIR', 'monitor_graphic.jpg') FROM DUAL");
    if (rset.next())
    {
      BFILE bfile = ((OracleResultSet)rset).getBFILE (1);
      System.out.println("result of fileIsOpen() before opening file : " + bfile.isFileOpen());
      bfile.openFile();
      System.out.println("result of fileIsOpen() after opening file : " + bfile.isFileOpen());

      bfile.closeFile();
      System.out.println("result of fileIsOpen() after closing file : " + bfile.isFileOpen());       

      CallableStatement cstmt = conn.prepareCall (
         "BEGIN DBMS_LOB.FILEOPEN(?,DBMS_LOB.LOB_READONLY); END;");
      cstmt.registerOutParameter( 1, OracleTypes.BFILE );
      ((OracleCallableStatement)cstmt).setBFILE(1, bfile);
      cstmt.execute();
      bfile = ((OracleCallableStatement)cstmt).getBFILE(1);

      System.out.println("result of fileIsOpen() after opening file again with PL/SQL : " 
        + bfile.isFileOpen());
      
      bfile.closeFile();
      System.out.println("result of fileIsOpen() after closing file : " + bfile.isFileOpen());       
   }
    stmt.close();
    conn.close();
  }
}

