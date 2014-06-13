/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/llength.java */

/* Getting the length of a LOB
 * Pure JDBC -- no Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver llength
*/
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Clob;
import java.sql.SQLException;

public class llength
{

  public static void main (String args [])
       throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery 
          ("SELECT ad_sourcetext FROM Print_media WHERE product_id = 3106");
    if (rset.next())
    {
      Clob clob = rset.getClob (1);
      System.out.println("Length of this column is : " + clob.length());
    }
    stmt.close();
    conn.close();
  }
}
