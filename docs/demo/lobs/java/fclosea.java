/* This file is installed in the following path when you install
 * the database: $ORACLE_HOME/rdbms/demo/lobs/java/fclosea.java */

/* Closing all open BFILEs using DBMS_LOB.FILECLOSEALL
 * Uses Oracle proprietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver fclosea
*/

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.jdbc.OracleResultSet;
import oracle.sql.BFILE;

public class fclosea
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
      BFILE bfile1 = ((OracleResultSet)rset).getBFILE (1);
      rset = stmt.executeQuery (
        "SELECT BFILENAME('MEDIA_DIR', 'keyboard_graphic.jpg')" 
        + " FROM DUAL");
      if (rset.next())
      {
        BFILE bfile2 = ((OracleResultSet)rset).getBFILE (1);
        rset.close();

        bfile1.openFile ();
        bfile2.openFile ();

        // A real program would manipulate the open BFILES here.

        stmt.execute("BEGIN DBMS_LOB.FILECLOSEALL; END;" );

        System.out.println("Result for first bfile of oracle.sql.BFILE.isFileOpen() "
          + " after DBMS_LOB.FILECLOSEALL : " 
          + bfile1.isFileOpen());
        System.out.println("Result for second bfile of oracle.sql.BFILE.isFileOpen() "
          + "after DBMS_LOB.FILECLOSEALL : " 
          + bfile1.isFileOpen());
      }
    }
    stmt.close();
    conn.close();
  }
}
