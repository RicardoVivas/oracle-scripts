/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/fpattern.java */

/* Checking if a pattern exists in a BFILE using position API. 
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver fpattern
*/

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.BFILE;
import oracle.jdbc.OracleResultSet;

public class fpattern
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    String pattern = new String("children"); 

    ResultSet rset = stmt.executeQuery (
       "SELECT ad_graphic FROM Print_media" 
       + " WHERE product_id = 3106 AND ad_id = 13001");
    if (rset.next())
    {
      BFILE bfile = ((OracleResultSet)rset).getBFILE (1);
      bfile.openFile();
      System.out.println("Results of Pattern Comparison : " 
         + bfile.position(pattern.getBytes(), 1));
      bfile.closeFile();
    }
    stmt.close();
    conn.close();
  }
}
