/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/listempb.java */

/* Checking if a BLOB is temporary.
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver listempb
*/
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Blob;
import java.sql.SQLException;

import oracle.sql.BLOB;

public class listempb
{
  public static void main (String args [])
       throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    System.out.println( "Select permanent lob from table." );
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery (
      "SELECT ad_composite FROM Print_media"
      + " WHERE product_id = 3060 AND ad_id = 11001");
    if (rset.next())
    {
      Blob blob = rset.getBlob (1);
      System.out.println( "Is blob temporary: " + ((BLOB)blob).isTemporary());
    }
    stmt.close();

    System.out.println( "Create temporary lob via API." );
    Blob blob = BLOB.createTemporary( conn, false, BLOB.DURATION_SESSION );
    // In JDK6 this could be Blob blob = conn.createBlob();

    System.out.println( "Is blob temporary: " + ((BLOB)blob).isTemporary());

    ((BLOB)blob).freeTemporary();
    // In JDK6 this could be blob.free();

    conn.close();
  }
}
