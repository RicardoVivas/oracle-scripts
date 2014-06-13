/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/fupdate.java */

/* Updating a BFILE column. 
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver fupdate
*/

import java.sql.Connection;
import java.sql.Statement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.BFILE;
import oracle.jdbc.OracleResultSet;
import oracle.jdbc.OraclePreparedStatement;

public class fupdate
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

      PreparedStatement pstmt = conn.prepareStatement (
        "UPDATE Print_media SET ad_graphic = ?" 
        + " WHERE product_id = 3060 AND ad_id = 11001");
      ((OraclePreparedStatement)pstmt).setBFILE(1, bfile);
      pstmt.execute();
      System.out.println( "PRINT_MEDIA row updated with BFILE" );
      pstmt.close();
    }
    stmt.close();
    conn.commit();
    conn.close();
  }
}
