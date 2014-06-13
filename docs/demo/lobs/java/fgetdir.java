/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/fgetdir.java */

/* Getting the directory alias and filename of a BFILE 
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver fgetdir
*/

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.BFILE;
import oracle.jdbc.OracleResultSet;

public class fgetdir
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery (
       "SELECT ad_graphic FROM Print_media" 
       + " WHERE product_id = 3106 AND ad_id = 13001");
    if (rset.next())
    {
      BFILE bfile = ((OracleResultSet)rset).getBFILE (1);
      System.out.println("Directory alias: " + bfile.getDirAlias());
      System.out.println("File name: " + bfile.getName());
    }
    stmt.close();
    conn.close();
  }
}
