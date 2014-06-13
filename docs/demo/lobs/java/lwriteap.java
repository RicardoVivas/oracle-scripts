/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/lwriteap.java */

/* Append data to blob by getting length and start writing there. 
 * Pur JDBC -- no Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver lwriteap
*/
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Blob;
import java.sql.SQLException;


public class lwriteap
{
  public static void main (String args [])
       throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery (
        "SELECT ad_composite FROM Print_media" 
         + " WHERE product_id = 2056 AND ad_id = 12001 FOR UPDATE");
    if (rset.next())
    {
      Blob blob = rset.getBlob (1);
      long endpos = blob.length();
      byte [] buf = { 1, 2, 3, 4, 5, 6, 8, 9, 10 };
      blob.setBytes(endpos, buf);
    }
    stmt.close();
    conn.commit();
    conn.close();
    System.out.println( "lwriteap done." );
  }
}
