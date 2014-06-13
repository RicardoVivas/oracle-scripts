/* This file is installed in the following path when you install
the database: $ORACLE_HOME/rdbms/demo/lobs/java/lappend.java */

/* Appending one LOB to another using JDBC stream APIs
 * Depending on the size, it may be  better to do this
 * with PL/SQL called from JDBC so as to not move the bits back and forth.
 * Pure jdbc -- no Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver lappend
*/

import java.io.InputStream;
import java.io.OutputStream;

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Blob;

public class lappend
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    conn.setAutoCommit (false);
    Statement stmt = conn.createStatement();
    ResultSet rst = stmt.executeQuery
      ("SELECT ad_photo FROM Print_media" 
       + " WHERE product_id = 2268 AND ad_id = 21001");
    Blob src = (rst.next()) ? rst.getBlob(1) : null;
    rst.close();

    rst = stmt.executeQuery 
      ("SELECT ad_photo FROM Print_media" 
       + " WHERE product_id = 3060 AND ad_id = 11001 FOR UPDATE");
    Blob dest = (rst.next()) ? rst.getBlob(1) : null;

    // To append, start writing at the end of the LOB.
    InputStream in = src.getBinaryStream();
    OutputStream out = dest.setBinaryStream(dest.length()); 

    int length;
    byte[] buffer = new byte[32768];
    while ((length = in.read(buffer)) != -1) out.write( buffer, 0, length);

    out.close();
    in.close();
    stmt.close();
    conn.commit();
    conn.close();
    System.out.println( "lappend done." );
  }
}
