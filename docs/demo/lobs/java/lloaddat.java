/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/lloaddat.java */

/* Use streaming API to copy from BFILE to BLOB, replacing original contents.
 * One could also overwrite part of the BLOB if desired.
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver lloaddat
*/
import java.io.InputStream;
import java.io.OutputStream;

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Blob;
import java.sql.SQLException;

import oracle.jdbc.OracleResultSet;
import oracle.sql.BFILE;

public class lloaddat
{
  public static void main (String args [])
     throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    Statement stmt = conn.createStatement ();
    ResultSet rset = stmt.executeQuery (
      "SELECT BFILENAME('MEDIA_DIR', 'keyboard_3106.txt') FROM DUAL");
    if (rset.next())
    {
      BFILE bfile = ((OracleResultSet)rset).getBFILE (1);
      bfile.openFile();
      InputStream in = bfile.getBinaryStream();

      rset = stmt.executeQuery (
        "SELECT ad_photo FROM Print_media WHERE product_id = 3106" 
        + " AND AD_ID = 13001 FOR UPDATE");
      if (rset.next())
      {
        Blob blob = rset.getBlob (1);
        blob.truncate(0L);
        byte buf[] = new byte[1000];

        // Fetch the output stream for blob: 
        OutputStream out = blob.setBinaryStream(1L);

        int length = 0;
        int pos = 0;
        while ((in != null) && (out != null) && ((length = in.read(buf)) != -1)) 
        {
          System.out.println(
                             "Pos = " + pos + ".  Length = " + length);
          pos += length;
          out.write(buf, pos, length);
        }
        in.close();
        out.flush();
        out.close();
        bfile.closeFile();
      }
    }
    stmt.close();
    conn.commit();
    conn.close();
  }
}
