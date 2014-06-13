/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/lisopen.java */

/* Checking if LOB is open
 * Use Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver lisopen
*/
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Blob;
import java.sql.SQLException;

import oracle.sql.BLOB;

public class lisopen
{
  public static void main (String args [])
       throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery (
          "SELECT ad_composite FROM Print_media"
          + " WHERE product_id = 3060 AND ad_id = 11001");
   if (rset.next())
   {
     Blob blob = rset.getBlob (1);
     System.out.println( "Is blob open: " + ((BLOB)blob).isOpen());
     ((BLOB)blob).open(BLOB.MODE_READONLY);
     System.out.println( "Is blob open: " + ((BLOB)blob).isOpen());
     ((BLOB)blob).close();
     System.out.println( "Is blob open: " + ((BLOB)blob).isOpen());
   }
   stmt.close();
   conn.close();
  }
}
