/* This file is installed in the following path when you install
 * the database: $ORACLE_HOME/rdbms/demo/lobs/java/lcompare.java */

/* Comparing two BLOBs using position API.
 * Pure jdbc -- no Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver lcompare
*/

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Blob;
import java.sql.SQLException;

public class lcompare
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    conn.setAutoCommit (false);

    Statement stmt = conn.createStatement ();
    ResultSet rst = stmt.executeQuery
      ( "SELECT ad_composite FROM Print_media" 
       + " WHERE product_id = 2056 AND ad_id = 12001");
    Blob lob1 = (rst.next()) ?  rst.getBlob(1) : null;
    rst.close();

    rst = stmt.executeQuery 
      ("SELECT ad_composite FROM Print_media" 
       + " WHERE product_id = 3106 AND ad_id = 13001");
    Blob lob2 = (rst.next()) ? rst.getBlob(1) : null;
    rst.close();

    if (lob1.length() > lob2.length()) 
      System.out.println ("Looking for LOB2 inside LOB1. result = " 
                          + Long.toString(lob1.position(lob2, 1)));
    else
      System.out.println("Looking for LOB1 inside LOB2.  result = " 
                         + Long.toString(lob2.position(lob1, 1)));

    stmt.close();
    conn.commit();
    conn.close();
  }
}
