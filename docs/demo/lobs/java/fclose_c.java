/* This file is installed in the following path when you install
 * the database: $ORACLE_HOME/rdbms/demo/lobs/java/fclose_c.java */

/* Closing a BFILE with close(). 
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver fclose_c
*/

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.jdbc.OracleResultSet;
import oracle.sql.BFILE;

public class fclose_c
{
  public static void main (String args [])
       throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    String sql = "SELECT BFILENAME('MEDIA_DIR', 'keyboard_graphic.jpg') FROM DUAL";
    ResultSet rset = stmt.executeQuery (
      "SELECT BFILENAME('MEDIA_DIR', 'keyboard_graphic.jpg') FROM DUAL");
    if (rset.next())
    {
      BFILE bfile = ((OracleResultSet)rset).getBFILE (1);
      bfile.open();
      System.out.println ("The file was opened oracle.sql.BFILE.open().");
      bfile.close();
      System.out.println ("The file was closed by oracle.sql.BFILE.close().");
    }
    stmt.close();
    conn.close();
  }
}
