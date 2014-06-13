/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/linstr.java */

/* Seeing if a pattern exists in a clob.
 * Pure JDBC -- no Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver linstr
*/
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Clob;
import java.sql.SQLException;

public class linstr
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery (
       "SELECT ad_sourcetext FROM Print_media" 
       + " WHERE product_id = 2268 AND ad_id = 21001");
    if (rset.next())
    {
      Clob clob = rset.getClob (1);
      System.out.println("Pattern found at position " + clob.position("Hayes", 1L ) );
    }
    stmt.close();
    conn.close();
  }
}
