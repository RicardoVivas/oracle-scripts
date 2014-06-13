/* This file is installed in the following path when you install
 * the database: $ORACLE_HOME/rdbms/demo/lobs/java/fclose_f.java */

/* Closing a BFILE with closeFile API. 
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver fclose_f
*/

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.jdbc.OracleResultSet;
import oracle.sql.BFILE;

public class fclose_f
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery (
       "SELECT BFILENAME('MEDIA_DIR','keyboard_graphic.jpg') FROM DUAL");

    if (rset.next())
    {
      BFILE bfile = ((OracleResultSet)rset).getBFILE (1);
      System.out.println("Result of oracle.sql.BFILE.isFileOpen() after fetch : " 
                         +  bfile.isFileOpen());

      bfile.openFile();
      System.out.println("Result of oracle.sql.BFILE.isFileOpen() after openFile : "
                         + bfile.isFileOpen());

      bfile.closeFile();
      System.out.println("Result of oracle.sql.BFILE.isFileOpen() after closeFile : " 
                         + bfile.isFileOpen());
    }
    stmt.close();
    conn.close();
  }
}
