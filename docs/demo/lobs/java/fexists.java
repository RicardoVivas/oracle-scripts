/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/fexists.java */

/* Checking if a BFILE exists. 
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver fexists
*/

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.BFILE;
import oracle.jdbc.OracleResultSet;

public class fexists
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery ( 
     "SELECT ad_graphic FROM Print_media WHERE product_id = 3106 AND ad_id = 13001");
    if (rset.next())
    {
      BFILE bfile = ((OracleResultSet)rset).getBFILE (1);
      System.out.println("Result from fileExists(): " + bfile.fileExists());
    }
    stmt.close();
    conn.close();
  }
}
