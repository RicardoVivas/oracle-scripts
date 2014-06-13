import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class LobDemoConnectionFactory
{
  public static Connection getConnection() throws SQLException
  {
    Connection conn = null;
    try {
      conn = DriverManager.getConnection ("jdbc:oracle:oci8:@", "pm", "pm");
    } catch( SQLException ex ) 
    { 
      if("No suitable driver".equals( ex.getMessage()))
      {
        System.out.println("Oracle driver not found.");
        System.out.println("Must place suitable Oracle jar file such as ojdbc5.jar in classpath.");
        System.out.println("For JDK 5, please invoke with: " );
        System.out.println("java  -Djdbc.drivers=oracle.jdbc.OracleDriver <demo>" );
      }
      throw ex;
    }
    return conn;
  }
}
