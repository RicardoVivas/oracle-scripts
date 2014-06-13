/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/lcopy.java */

/* Copying all or part of a LOB to another LOB using stream APIs.
 * Pure JDBC - does not require Oracle specific classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver lcopy
*/

import java.io.InputStream;
import java.io.OutputStream;

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Blob;
import java.sql.SQLException;

public class lcopy
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery (
       "SELECT ad_photo FROM Print_media" 
       + " WHERE product_id = 3060 AND ad_id = 11001");
    if (rset.next())
    {
      Blob sourceBlob = rset.getBlob (1);
      InputStream in = sourceBlob.getBinaryStream();
   
      rset = stmt.executeQuery (
        "SELECT ad_photo FROM Print_media" 
        + " WHERE product_id = 3106 AND ad_id = 13001 FOR UPDATE");
      if (rset.next())
      {
        Blob destinationBlob = rset.getBlob (1);
        destinationBlob.truncate(0L); 
        // One might or might not want to truncate here.
        OutputStream out = destinationBlob.setBinaryStream(1L);
        byte[] buf = new byte[2000];
        // One could loop here to write it all.
        int len = in.read(buf);
        out.write(buf, 0, len);
        out.flush();
        out.close();
        System.out.println( "Copied data from source Blob to destination Blob in table." );
      }
      in.close();
    }
    stmt.close();
    conn.commit();
    conn.close();
  }
}
