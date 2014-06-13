/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/fcompare.java */

/* Comparing all or parts of two BFILES using position API 
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver lcompare
*/

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.BFILE;
import oracle.jdbc.OracleResultSet;

public class fcompare
{
  public static void main (String args [])
    throws Exception
  {
    Connection conn = LobDemoConnectionFactory.getConnection();
    conn.setAutoCommit (false);
    Statement stmt = conn.createStatement ();

    ResultSet  rset = stmt.executeQuery (
       "SELECT ad_graphic FROM Print_media WHERE product_id = 3106");
    if (rset.next())
    {
      BFILE bfile1 = ((OracleResultSet)rset).getBFILE (1);
      rset = stmt.executeQuery (
        "SELECT BFILENAME('MEDIA_DIR', 'keyboard_3106.txt') FROM DUAL");
      if (rset.next())
      {
        BFILE bfile2 = ((OracleResultSet)rset).getBFILE (1);

        bfile1.openFile ();
        bfile2.openFile ();

        if (bfile1.length() > bfile2.length()) 
          System.out.println("Looking for LOB2 inside LOB1.  result = " +
                             bfile1.position(bfile2, 1));
        else
          System.out.println("Looking for LOB1 inside LOB2.  result = " +
                             bfile2.position(bfile1, 1));
        bfile2.closeFile();
        bfile1.closeFile();
      }
    }
    stmt.close();
    conn.commit();
    conn.close();
  }
}
