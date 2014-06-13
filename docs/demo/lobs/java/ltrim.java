/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/java/ltrim.java */

/* Trimming BLOBs and CLOBs.
 * Pure JDBC -- no Oracle propietary classes.
 * In JDK5 invoke with java -Djdbc.drivers=oracle.jdbc.OracleDriver ltrim
 */

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Blob;
import java.sql.Clob;
import java.sql.SQLException;

class ltrim 
{ 
  public static void main (String args []) 
       throws Exception 
  { 
    Connection conn = LobDemoConnectionFactory.getConnection();
    conn.setAutoCommit( false );
    createTables( conn );
    Statement stmt = conn.createStatement (); 
    ResultSet rset = stmt.executeQuery ("select * from basic_lob_table"); 
    while (rset.next ()) 
    { 
      Blob blob = rset.getBlob (2); 
      Clob clob = rset.getClob (3); 

      System.out.println ("blob.length()="+blob.length()); 
      System.out.println ("clob.length()="+clob.length()); 

      System.out.println ("Trim the lob to length = 6"); 
      blob.truncate(6L); 
      clob.truncate(6L); 

      System.out.println ("blob.length()="+blob.length()); 
      System.out.println ("clob.length()="+clob.length()); 
    } 
    stmt.close (); 
    dropTables( conn );
    conn.close (); 
  }

  static void createTables( Connection conn ) throws SQLException
  {
    dropTables( conn );
    Statement stmt = conn.createStatement();
    try 
    { 
    stmt.execute ("create table basic_lob_table"
        + "(x varchar2 (30), b blob, c clob)"); 

    stmt.execute ("insert into basic_lob_table values('one'," 
        + " '010101010101010101010101010101', 'onetwothreefour')"); 

    } 
    finally{ stmt.close();}
  } 

  static void dropTables( Connection conn ) throws SQLException
  {
    Statement stmt = conn.createStatement();
    try 
    { 
      stmt.execute ("drop table basic_lob_table"); 
    } 
    catch (SQLException e) { } 
    finally{ stmt.close();}
  } 
} 
