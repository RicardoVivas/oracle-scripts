/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/finsert.java */

/* Inserting a row containing a BFILE by initializing a BFILE.
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver finsert
*/

import java.sql.Connection;
import java.sql.Statement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.BFILE;
import oracle.jdbc.OracleResultSet;
import oracle.jdbc.OraclePreparedStatement;

public class finsert
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    conn.setAutoCommit( false );
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery (
      "SELECT BFILENAME('MEDIA_DIR','monitor_graphic.jpg') FROM DUAL");
    if (rset.next())
    {
      BFILE bfile = ((OracleResultSet)rset).getBFILE (1);
      PreparedStatement pstmt = conn.prepareStatement (
         "INSERT INTO Print_media (product_id, ad_graphic, ad_id)"
         + " VALUES (3060, ?, 11003)");
      ((OraclePreparedStatement)pstmt).setBFILE(1, bfile);
      pstmt.execute();
      pstmt.close();
    }
    stmt.close();
    conn.rollback(); 
    /* Rollback so this works more than once! 
       We would get a primary key violation after the first time otherwise.
       A real program would have some way of getting or creating the keys */    
    conn.close();
    System.out.println( "finsert done." );
  }
}
