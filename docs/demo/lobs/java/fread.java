/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/fread.java */

/* Reading data from a BFILE. 
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver fread
*/
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.BFILE;
import oracle.jdbc.OracleResultSet;

public class fread
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
      bfile.openFile();
      byte [] b = bfile.getBytes( 1L, 100 );
      for( int i=0; i < b.length; i++ )
        System.out.println( "index: " + i + " value: " + b[i] );
      bfile.closeFile();
    }
    stmt.close();
    conn.commit();
    conn.close();
  }
}
