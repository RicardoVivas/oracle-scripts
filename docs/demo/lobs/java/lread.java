/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/lread.java */

/* Reading LOB data
 * Pure JDBC -- no Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver lread
*/
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Blob;
import java.sql.SQLException;

public class lread
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery (
         "SELECT ad_composite FROM Print_media"
         + " WHERE product_id = 2056 AND ad_id = 12001");
    if (rset.next())
    {
      Blob blob = rset.getBlob(1);
      byte [] b = blob.getBytes(100L, 20);
      for( int i=0; i < b.length; i++ )
        System.out.println( "index: " + i + " value: " + b[i] );
    }
    stmt.close();
    conn.close();
  }
}
