/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/listempb.java */

/* Checking if a CLOB is temporary.
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver listempc
*/
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Clob;
import java.sql.SQLException;

import oracle.sql.CLOB;

public class listempc
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    System.out.println( "Select permanent lob from table." );
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery 
          ("SELECT ad_sourcetext FROM Print_media WHERE product_id = 3106");
    if (rset.next())
    {
      Clob clob = rset.getClob (1);
      System.out.println("Is blob temporary: " + ((CLOB)clob).isTemporary());
    }
    stmt.close();

    System.out.println( "Create temporary lob via API." );
    Clob clob = CLOB.createTemporary( conn, false, CLOB.DURATION_SESSION );
    // In JDK6 this could be Blob blob = conn.createClob();

    System.out.println( "Is clob temporary: " + ((CLOB)clob).isTemporary());

    ((CLOB)clob).freeTemporary();
    // In JDK6 this could be clob.free();

    conn.close();
  }
}
