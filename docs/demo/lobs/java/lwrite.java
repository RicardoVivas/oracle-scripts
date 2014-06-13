/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/lwrite.java */

/* Overwrite first few bytes or a blob, remainder are unchanged.
 * Pure JDBC -- no Oracle proprietary classes
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver lwrite
 */

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Blob;
import java.sql.SQLException;

public class lwrite
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
      byte [] buf = { 1, 2, 3, 4, 5, 6, 7, 8 };
      blob.setBytes(1L, buf);
    }
    stmt.close();
    conn.commit();
    conn.close();
    System.out.println( "lwrite done." );
  }
}
