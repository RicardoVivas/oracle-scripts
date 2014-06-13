/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/linsert.java */

/* Get a blob from one table and insert it into another.
 * Pure JDBC -- no Oracle proprietary classes needed.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver fclose_c
*/

import java.sql.Connection;
import java.sql.Statement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Blob;
import java.sql.SQLException;

public class linsert
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    conn.setAutoCommit( false );
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery ( 
      "SELECT ad_photo FROM Print_media WHERE product_id = 3106 AND ad_id = 13001");
    if (rset.next())
    {
      Blob adphotoBlob = rset.getBlob (1);
      PreparedStatement pstmt =  conn.prepareStatement(
        "INSERT INTO Print_media (product_id, ad_id, ad_photo) VALUES (2268, 21003, ?)");
      pstmt.setBlob(1, adphotoBlob);
      pstmt.execute();
      pstmt.close();
    }
    conn.rollback();
    /* Rollback so this works more than once! 
       We would get a primary key violation after the first time otherwise.
       A real program would have some way of getting or creating the keys */    
    conn.close();
    System.out.println( "linsert done." );
  }
}
