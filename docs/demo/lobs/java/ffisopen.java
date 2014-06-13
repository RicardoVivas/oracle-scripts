/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/ffisopen.java */

/* Checking if a BFILE is open with isFileOpen API.
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver ffisopen
*/

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.BFILE;
import oracle.jdbc.OracleResultSet;

public class ffisopen
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

      boolean result = bfile.isFileOpen();
      System.out.println("result of fileIsOpen() before opening file : " + result);
      if (!result) 
        bfile.openFile();

      System.out.println("result of fileIsOpen() after opening file : " 
         + bfile.isFileOpen());

      bfile.closeFile();
    }
    stmt.close();
    conn.close();
  }
}
