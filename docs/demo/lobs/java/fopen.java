/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/fopen.java */

/* Opening a BFILE with open() API and closing with close().
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver fopen
*/
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.BFILE;
import oracle.jdbc.OracleResultSet;

public class fopen
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
      BFILE  bfile = ((OracleResultSet)rset).getBFILE (1);
      bfile.open();
      System.out.println ("the file is now open");
      bfile.close();
    }
    stmt.close();
    conn.close();
  }
}
