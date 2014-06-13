/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/lerase.java */

/* Erasing part of a LOB
 * For a larger erase size it might be better to use DBMS_LOB.ERASE.
 * Pure JDBC -- no Oracle proprietary classes used.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver fclose_c
*/
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Blob;
import java.sql.SQLException;


public class lerase
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    int eraseAmount = 30;
    long erasePosition = 2000L;
    ResultSet rset = stmt.executeQuery (
       "SELECT ad_photo FROM Print_media" 
       + " WHERE product_id = 2056 AND ad_id = 12001 FOR UPDATE");
    if (rset.next())
    {
      Blob blob = rset.getBlob (1);
      byte [] buf = new byte[eraseAmount];
      blob.setBytes( erasePosition, buf );
      System.out.println( "Erased " + eraseAmount + " bytes at position " + erasePosition );
    }
    stmt.close();
    conn.commit();
    conn.close();
  }
}
