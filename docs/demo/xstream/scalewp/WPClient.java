/* $Header: rdbms/demo/xstream/scalewp/WPClient.java /st_rdbms_11.2.0/1 2010/08/13 18:32:29 vchandar Exp $ */

/* Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. */

/*
   DESCRIPTION
     WPClient.java - XStream Client implementation for Oracle Whitepaper
     "Building Highly Scalable Web Application with XStream"
     Client program that reads the order, order_line changes
     from Web Front end database using XStream Out, build the corressponding
     customer, item table updates , sends them over to the sharded customer/
     item databases using XStream In apis. 
    
     Usage : java WPClient <propertiesfile> <xstream_admin_passwd>

   PRIVATE CLASSES
    XStreamInfo - Encapsulates connection information to XStream
    Position    - Provides methods for position management for recovery

   NOTES
    Please refer to wp.properties sample file for information on the
    input configuration

   MODIFIED    (MM/DD/YY)
    vchandar    08/12/10 - Creation
 */

/**
 *  @version $Header: rdbms/demo/xstream/scalewp/WPClient.java /st_rdbms_11.2.0/1 2010/08/13 18:32:29 vchandar Exp $
 *  @author  vchandar
 *  @since   release specific (what release of product did this appear in)
 */
/**
 * WPClient - Client program that reads the order, order_line changes
 * from Web Front end data base using XStream Out, build the corressponding
 * customer, item table updates , sends them over to the sharded customer/
 * item databases using XStream In apis. 
 * 
 */
import oracle.streams.*;
import oracle.jdbc.internal.OracleConnection;
import oracle.jdbc.*;
import oracle.sql.*;
import java.sql.*;
import java.util.*;
import java.nio.ByteBuffer;

/**
 * Encapsulate all the information needed for connecting to a XStream 
 * server
 */
class XStreamInfo 
{
  /**
   * Host running the XStream server
   */
  private String host;
  /**
   * SID of the XStream Server DB
   */
  private String sid;
  /**
   * Listener port of the DB
   */
  private int port;
  /**
   * Server name
   */
  private String name;
  /**
   * XIN connection object to talk to xin server
   */
  private XStreamIn xin;
  /**
   * XOUT connection object to talk to xout server
   */
  private XStreamOut xout;
  /**
   * DB stream admin login username
   */
  private String userName;
  /**
   * DB stream admin password
   */
  private String passWord;

  /**
   * Initialize the XStreamInfo object with host,sid, port, servername,
   * username,pwd needed to establish a XStream Connection
   */
  XStreamInfo(String h, String s,int p, String n, String usr, String pwd)
  {
    host = h;
    sid = s;
    port = p;
    name = n;
    xin = null;
    xout = null;
    userName = usr;
    passWord = pwd;
  }

  /**
   * Returns the jdbc connection string to connect to the DB
   */
  String getConnectionString()
  {
    return "jdbc:oracle:oci:@"+host+":"+port+":"+sid;
  }

  /**
   * Returns the servername
   */
  String getServerName()
  {
    return name;
  }

  /**
   * Returns true if this info object encapsulates info about an xin
   * false if its xout
   */
  boolean isXinInfo()
  {
    return (xin != null);
  }

  /**
   * Returns the XIN connection object
   */
  XStreamIn getXin()
  {
    return xin;
  }

  /**
   * Returns the XOUT connection object
   */
  XStreamOut getXout()
  {
    return xout;
  }

  /**
   * create a connection to an Oracle Database
   */
  private Connection createConnection()
  {
    String url = getConnectionString();
    try
    {
      DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
      return DriverManager.getConnection(url, userName, passWord);
    }
    catch(Exception e)
    {
      System.out.println("ERROR : failed to establish DB connection to: " 
                         +url);
      e.printStackTrace();
      return null;
    }
  }

  /**
   *  attach to the XStream Inbound Server
   */
  void attachInbound()
  {
    xout = null;
    try
    {
      /* Create a connection to the database with the XIN */
      Connection in_conn = createConnection();
      /* Attach to the inbound server */
      xin = XStreamIn.attach((OracleConnection)in_conn,
                             name,
                             "WPDEMOINCLIENT" , 
                             XStreamIn.DEFAULT_MODE);
   
      System.out.println("Attached to inbound server:"+
                         name);
    }
    catch(Exception e)
    {
      System.out.println("ERROR :cannot attach to inbound server: "
                          + name);
      System.out.println(e.getMessage());
      e.printStackTrace();
    }   
  }

  /**
   * Attach to the XOUT Server 
   */
  void attachOutbound(byte[] lastPosition)
  {
    xin = null;
    try
    {
      /* when attach to an outbound server, client needs to tell outbound
       * server the last position. 
       */
       Connection out_conn = createConnection();
       xout = XStreamOut.attach((OracleConnection)out_conn,
                                name,
                               lastPosition, XStreamOut.DEFAULT_MODE);
       System.out.println("Attached to outbound server:"+
                           name);
    }
    catch(Exception e)
    {
      System.out.println("ERROR : cannot attach to outbound server: "
                         + name);
      System.out.println(e.getMessage());
      e.printStackTrace();
    }
  }


  /**
   * Detaches from the XStream server 
   */
  void detach()
  {
    try 
    {
      if (isXinInfo())
      {
        byte[] processedLowPosition = xin.detach(XStreamIn.DEFAULT_MODE);
        System.out.print("XIN server " + name + 
                         " detached, processed low Position is: ");     
        Position.printHex(processedLowPosition);
      }
      else
      {
        xout.detach(XStreamOut.DEFAULT_MODE);
        System.out.println("XOUT server "+ name + " detached");
      }
    }
    catch(Exception e)
    {
      System.out.println("ERROR: cannot detach from the XSTREAM server: "
                         + name);
      System.out.println(e.getMessage());
      e.printStackTrace();
    }
  }
}


/**
 * Provides a wrapper to manipulate over the positions for recoverability.
 * We extend the position array provided by Xout by some bytes to accomodate
 * for the additional lcrs we require. The values encoded in these additional
 * bytes are incremented for each lcr in the xin transactions we generate.
 * Since, on recovery, we need the complete source txn to be able to generate
 * the proper updates to item and customer tables, we retain the position array
 * of the commit lcr of the source txn as the base for xin positions. This 
 * way, xout can send the whole source txn on restart and the client can still
 * be stateless as well as fault tolerant
 */
class Position
{
  /**
   * The XOUT position used as a base, from which newer positions 
   * are generated
   */
  private byte[] basePosition;
    
  /**
   * additional lcr sequence numbers
   */
  private long lcrSequence;
    
  Position(byte[] bp)
  {
    lcrSequence = 0;
    basePosition = bp;
  }

  /**
   * Obtains the next position as a byte array, with respect to the
   * base position
   */
  byte[] getNextPosition()
  {
    byte[] ret = null;
    lcrSequence++;
    byte[] slab = toByteArray(lcrSequence);
    ret = new byte[basePosition.length + slab.length];
    /* copy the base position */
    System.arraycopy(basePosition, 0, ret, 0, basePosition.length);
    /* copy the lcr sequence */
    System.arraycopy(slab, 0, ret, basePosition.length, slab.length);
    return ret;
  }


  /**
   * Returns true if pos1 is < then pos2
   */
  public static boolean isPositionLower(byte[] pos1, byte[] pos2)
  {
    ByteBuffer b1 = ByteBuffer.wrap(pos1);
    ByteBuffer b2 = ByteBuffer.wrap(pos2);
    return (b1.compareTo(b2) < 0);
  }

  /**
   * Converts a long variable to a byte array, used in position generation
   */
  private static byte[] toByteArray(long data) 
  {
    return new byte[] {
            (byte)((data >> 56) & 0xff),
            (byte)((data >> 48) & 0xff),
            (byte)((data >> 40) & 0xff),
            (byte)((data >> 32) & 0xff),
            (byte)((data >> 24) & 0xff),
            (byte)((data >> 16) & 0xff),
            (byte)((data >> 8) & 0xff),
            (byte)((data >> 0) & 0xff),
        };
  }

  /**
   * Prunes out the xin additional bytes from the position and
   * returns only the base position, to be passed into to XOUT
   * since, xout sends all the lcrs > a given start position,
   * We need to pass in a position less than the position of the first
   * lcr of the source txn. We do this by using the Commit SCN of the base 
   * position to construct a position array
   */
  public static byte[] getXoutPosition(byte[] xinPos) throws Exception
  {
    if (xinPos == null)
      return null;
    byte[] basePos = getBasePosition(xinPos);
     return XStreamUtility.convertSCNToPosition(
                             XStreamUtility.getCommitSCNFromPosition(basePos));
  }


  /**
   * Takes an xin position and removes extra bytes returning only the 
   * base xout position
   */
  public static byte[] getBasePosition(byte[] xinPos)
  {
    if (xinPos == null)
      return null;
        
    byte[] pad = toByteArray((long) 0);
    byte[] basePos = new byte[xinPos.length - pad.length];
    System.arraycopy(xinPos, 0, basePos, 0, basePos.length);
    return basePos;
  }


  /**
   * Prints a byte array as hex string 
   */
  public static void printHex(byte[] b) 
  {
    if (b == null)
      return;

    for (int i = 0; i < b.length; ++i) 
    {
      System.out.print(Integer.toHexString((b[i]&0xFF) | 0x100)
                               .substring(1,3));
    }
    System.out.println("");
  }

  public byte[] getBasePosition()
  {
    return basePosition;
  }
}


/**
 * WPClient attaches to one XOUT and pulls out inserts to orders, order_line
 * tables. And then constructs the updates to customer, item tables statically
 * partitioned across a number of databases, through an xin at each DB
 */
public class WPClient
{
  /**
   * User name for the XStream Admin user
   */
  public static String username = "wpadmin";

  /**
   * Password for the XStream admin user
   */
  public static String passwd = "";

  /**
   * To turn printing debug statements on/off
   */
  public static boolean DEBUG = true;
    

  /**
   * State about the databases, port, sid etc
   */
  /**
   * State on the XOUT from the web front end DB
   */
  XStreamInfo webDBInfo;
  /**
   * State of the customer DB XINs 
   */
  List<XStreamInfo> custDBInfo;
  /**
   * State of the item DB XINs
   */
  List<XStreamInfo> itemDBInfo;
   
  /**
   * Minimum position across all XStream Ins to be supplied to
   * XStream Out
   */
  public static byte[] minPosition = null;
  /**
   * Minimum low processed position across all the xstream ins
   */
  public static byte[] minLowWatermark = null;


  /**
   * PROCESSING STATE OF THE CLIENT
   */
   
  /** customer transaction which updates the customer balance
   * and also consolidates the order, order_line data 
   */
  List<LCR> customerTxn;
        
  /** Item transctions that update inventory, one per item xin */
  HashMap<XStreamInfo, List<LCR>> itemTxnMap;
    
  /**
   * Customer being processed currently
   */
  int custID = -1; 

  /**
   * Total cost of the customer bill
   */
  int cost = 0;

  /**
   * id of the current transaction id being processed.
   */
  String transactionId;

  /**
   * Position object to generate position in the new xin transactions
   */
  Position position;

  /**
   * Initializes all the XStreamInfo objects needed to connect to the 
   * various XStream servers
   */
  public WPClient(String configFileName, String pwd)
  {
    passwd = pwd;
    custID = -1;
    customerTxn = new ArrayList<LCR>();
    itemTxnMap = new HashMap<XStreamInfo, List<LCR>>();
    transactionId = null;
    custDBInfo = new ArrayList<XStreamInfo>();
    itemDBInfo = new ArrayList<XStreamInfo>();


    Properties config = new Properties();
    try {        
      config.load(this.getClass().getClassLoader()
                        .getResourceAsStream(configFileName));
    }
    catch(Exception e)
    {
      System.err.println("Error loading the config file :"+ config);
      System.err.println(e);
      System.exit(0);
    }
           
    DEBUG = Boolean.parseBoolean(config.getProperty("debug","true"));

    int numItemDB = 0,numCustDB = 0;

    /* parse the basic information for the configuration */        
    try {
       numItemDB = Integer.parseInt(getProperty("numItemDB", config));
    }
    catch(Exception e){
      System.err.println("Error parsing key : numItemDB");
      System.err.println(e);
      System.exit(0); 
    }
        

    try {
      numCustDB = Integer.parseInt(getProperty("numCustDB", config));
    }
    catch(Exception e){
      System.err.println("Error parsing key: numCustDB");
      System.err.println(e);
      System.exit(0);
    }

    /* Parse the XStreamInfo objects out of the properties file */
    webDBInfo = parseXStreamInfo("xout", config);
        
    for (int i = 1; i <= numCustDB; i++)
    {
      custDBInfo.add(parseXStreamInfo("cust"+i, config));
    }

    for (int i = 1; i <= numItemDB; i++)
    {
      itemDBInfo.add(parseXStreamInfo("item"+i, config));
    }
  }


  private XStreamInfo parseXStreamInfo(String key, Properties config)
  {
    XStreamInfo info = null;
    try {
      info = new XStreamInfo(getProperty(key + ".hostname", config),
                             getProperty(key + ".sid", config),
                             Integer.parseInt(getProperty(
                                   key + ".port", config)),
                             getProperty(key + ".name", config),
                             getProperty(key + ".username", config),
                             passwd);
            
    }
    catch (Exception e){
      System.err.println("Error parsing keys for :"+ key);
      System.err.println(e);
      System.exit(0);
    }
        
    return info;
  }

  private String getProperty(String key, Properties config) throws Exception
  {
    String p = config.getProperty(key);
    if (p == null)
      throw new Exception("Key : "+ key +" not specified");
    return p;
  }

  /**
   * Updates the minimum position across all the xins so that we can 
   * get the xout to re send out only the necessary data on failure
   */
  private void updateMinimumPosition(XStreamInfo info)
  {
    /* get the position of this xin */
    byte[] pos = info.getXin().getLastPosition();

    /* Update the min position across all the xins if this
     *  Xin's position is smaller than the rest
     */
    if (pos != null)
    {
      if (minPosition == null)
      {
        minPosition = pos;
      }
      else
      {
        if (Position.isPositionLower(pos, minPosition))
          minPosition = pos;
      }
      if (DEBUG)
      {    
        System.out.println("XIN "+ info.getServerName() +" at "+
                          "Position :");
        Position.printHex(pos);
      }
    }
  }

  /**
   *  Updates the minimum low processed watermark across all the xins
   *  so that we can let the xout know, after each batch of lcrs
   */
  private void updateMinimumLowProcessedWatermark(XStreamInfo info)
  {
    /* get the low watermark of this xin */
    byte[] wm = info.getXin().getProcessedLowWatermark();

    /* Update the min watermark across all the xins if this
     *  Xin's watermark is smaller than the rest
     */
    if (wm != null)
    {
      if (minLowWatermark == null)
      {
        minLowWatermark = wm;
      }
      else
      {
        if (Position.isPositionLower(wm, minLowWatermark))
          minLowWatermark = wm;
      }
      if (DEBUG)
      {    
        System.out.println("XIN "+ info.getServerName() +" at "+
                           "Low processed WM :");
        Position.printHex(wm);
      }
    }
  }

 
  /**
   * Get a XIN server to send the changes given a customer ID
   * For simplicity, we implement the hash with a modulo function.
   * A real implementation could have a sufficiently complex hash function
   * to account for the load distribution
   */
  private XStreamInfo getCustomerXin(int custID)
  {
    int xin = custID % custDBInfo.size();
    return custDBInfo.get(xin);
  }

  /**
   * Get a XIN server to send the item updates given an item id 
   * For simplicity, we implement the hash with a modulo function.
   * A real implementation could have a sufficiently complex hash function
   * to account for the load distribution
   */
  private XStreamInfo getItemXin(int itemID)
  {
    int xin = itemID % itemDBInfo.size();
    return itemDBInfo.get(xin);
  }

  /**
   * Attach to all the XStream Server processes. Find the minimum position
   * of all the xins and provide that to the xout.
   */
  public void initConnections() throws Exception
  {    
    /* create xins to the customer dbs */
    for (XStreamInfo info : custDBInfo)
    {
      info.attachInbound();
      updateMinimumPosition(info);
    }
        
    /* create xins to the item dbs */
    for (XStreamInfo info : itemDBInfo)
    {
      info.attachInbound();
      updateMinimumPosition(info);
    }

    byte[] minPos = Position.getXoutPosition(minPosition);
    System.out.println("Connecting to XOUT using position :");
    Position.printHex(minPos);
    /* create an xstream out connection to the web front databse*/
    webDBInfo.attachOutbound(minPos);
  }

  /**
   * Deatch from all the xstream servers
   */
  public void closeConnections()
  {
    webDBInfo.detach();
    /* Detach from the customer xins */
    for (XStreamInfo info : custDBInfo)
    {
      info.detach();
    }
        
    /* Detach from the item xins */
    for (XStreamInfo info : itemDBInfo)
    {
      info.detach();
    }
  }

  /**
   * Flush all the inflight data and update the low processed watermark
   * at the end of each batch for xout
   */
  private void flushData() throws Exception
  {
    try {
        
      /* flush the network */
      for (XStreamInfo info : custDBInfo)
      {
        info.getXin().flush(XStreamIn.DEFAULT_MODE);
        updateMinimumLowProcessedWatermark(info);
      }
        
      for (XStreamInfo info : itemDBInfo)
      {
        info.getXin().flush(XStreamIn.DEFAULT_MODE);
        updateMinimumLowProcessedWatermark(info);
      }

      byte[] minWM = Position.getXoutPosition(minLowWatermark);
            
      if (DEBUG)
      {                
        System.out.println("XOUT updated to min processed WM :");
        Position.printHex(minWM);
      }
                    
      if (minLowWatermark != null)
        webDBInfo.getXout().setProcessedLowWatermark(minWM,
                                             XStreamOut.DEFAULT_MODE);
    }
    catch(Exception e){
      System.out.println("ERROR: Flushing data "+ e);
      e.printStackTrace();
      throw e;
    }
  }

  /**
   * Utility function to add an lcr to the customer txn. The customer txn
   * consists of the balance update to the customer table and the original
   * inserts for orders/order_line
   */
  private void addLCRToCustomerTxn(LCR alcr) throws SQLException
  {
    alcr.setSourceTime(new oracle.sql.DATE(new java.sql.Date(
                                             System.currentTimeMillis())));
    alcr.setTransactionId(transactionId);
    customerTxn.add(alcr);
  }

  /**
   * Process an insert into order lcr. We save the customer id 
   * to construct the balance update. and then add this to the customer txn
   */
  private void processOrdersInsert(LCR alcr) throws Exception
  {
    ColumnValue[] vals = ((RowLCR) alcr).getNewValues();
    for (ColumnValue cv : vals){
      if (cv.getColumnName().equalsIgnoreCase("CUST_ID"))
      {
        custID = cv.getColumnData().intValue();
        if (DEBUG)
        {        
          System.out.println("Order from Customer :"+ custID);
        }
        break;
      }
    }
    /* add this lcr to the customer txn */
    addLCRToCustomerTxn(alcr);
  }
    

  /**
   * Process an insert into order_line lcr. We aggregate the total cost of
   * the order. and construct an update lcr for each item quantity that is
   * changed.
   */
  private void processOrderLineInsert(LCR alcr) throws Exception
  {
    int quantity = 0;
    int unitCost = 0;
    int itemID = -1;
        
    ColumnValue[] vals = ((RowLCR) alcr).getNewValues();
    for (ColumnValue cv : vals)
    {
      if (cv.getColumnName().equalsIgnoreCase("QUANTITY"))
      {
        quantity = cv.getColumnData().intValue();       
      }
      else if  (cv.getColumnName().equalsIgnoreCase("ITEM_ID"))
      {
        itemID = cv.getColumnData().intValue();
      }
      else if (cv.getColumnName().equalsIgnoreCase("COST"))
      {
        unitCost = cv.getColumnData().intValue();
      }
    }

    /* accumulate cost for the order */
    cost += unitCost * quantity;

    /* add this lcr to the customer txn */
    addLCRToCustomerTxn(alcr);

    /* create a update LCR for consolidating the inventory */
    XStreamInfo itemInfo = getItemXin(itemID);
    if (!itemTxnMap.containsKey(itemInfo)){
      itemTxnMap.put(itemInfo, new ArrayList<LCR>());
    }
      
    /* put in temporary position. We will generate
     * correct ones later 
     */
    RowLCR qtyUpdateLcr = new DefaultRowLCR(alcr.getSourceDatabaseName(), 
                                            RowLCR.UPDATE, 
                                            username.toUpperCase(),
                                            "ITEM", transactionId,
                                            null, null,
                                            new oracle.sql.DATE(
                                              new java.sql.Date(
                                                  System.currentTimeMillis())));
    vals = new ColumnValue[2];
    vals[0] = new DefaultColumnValue("ITEM_ID", new NUMBER(itemID));
    vals[1] = new DefaultColumnValue("QUANTITY", new NUMBER(quantity));
    qtyUpdateLcr.setNewValues(vals);
    /* Note that only the primary key values are needed for the old column
    * values. Including everything for code brevity */
    qtyUpdateLcr.setOldValues(vals);
    /* add to the appropriate xin item transaction */
    itemTxnMap.get(itemInfo).add(qtyUpdateLcr);
  }
    

  /**
   * Process a commit lcr. We send out the customer txn to an xin.
   * We go over all the lcrs in each of the item transactions and assign
   * a position to each lcr. This will ensure that this
   * program can be used with a single xin or multiple xins since the 
   * transaction ids and positions will be unique across all the xins
   */
  private void processCommit(LCR alcr) throws Exception
  {   
    /* Add Update to customer balance in the customer TXN */
    RowLCR balUpdateLcr = new DefaultRowLCR(alcr.getSourceDatabaseName(), 
                                            RowLCR.UPDATE, 
                                            username.toUpperCase(),
                                            "CUSTOMER", transactionId,
                                            null, null,
                                            new oracle.sql.DATE(
                                            new java.sql.Date(
                                              System.currentTimeMillis())));
    ColumnValue[] vals = new ColumnValue[2];
    vals[0] = new DefaultColumnValue("CUST_ID", new NUMBER(custID));
    vals[1] = new DefaultColumnValue("BALANCE", new NUMBER(cost));
    balUpdateLcr.setNewValues(vals);
    /* Note that only the primary key values are needed for the old column
     * values. Including everything for code brevity */
    balUpdateLcr.setOldValues(vals);
    customerTxn.add(balUpdateLcr);
        
    /* Add a commit to the customer TXN */
    addLCRToCustomerTxn(alcr);
       
    /* send the customer TXN to the appropriate xin */
    XStreamInfo custInfo =  getCustomerXin(custID);
    for (LCR lcr : customerTxn)
    {
      lcr.setPosition(position.getNextPosition());
      if (DEBUG)
      {        
        System.out.println("-- SENDING LCR to CUSTOMER XIN "+ 
                           custInfo.getServerName()+" ---");
        System.out.println(lcr);
      }
      custInfo.getXin().sendLCR(lcr, XStreamIn.DEFAULT_MODE);
    }


    /* Add Commit LCRs to each of the item xin transactions & set
     * position, transaction id for each of the xin transactions
     */
    for (XStreamInfo info : itemTxnMap.keySet())
    {
      /* add the commit lcr */
      alcr.setSourceTime(new oracle.sql.DATE(new java.sql.Date(
                                                 System.currentTimeMillis())));
      alcr.setTransactionId(transactionId);
      itemTxnMap.get(info).add(alcr);

      /* Send the item txn to the appropriate xin */
      for (LCR lcr : itemTxnMap.get(info))
      {
        lcr.setPosition(position.getNextPosition());
        if (DEBUG)
        {       
          System.out.println("-- SENDING LCR to ITEM XIN "+ 
                             info.getServerName()+" ---");
          System.out.println(lcr);
        }
        info.getXin().sendLCR(lcr, XStreamIn.DEFAULT_MODE);
      }
    }
                        
    /* clear out the lists and other txn specific state */
    customerTxn.clear();
    itemTxnMap.clear();
    cost = 0;
    transactionId = null;
    position = null;
  }
    

  /**
   * Main loop to get an lcr from xout and construct customer and 
   * item transactions at the different xins.
   */
  public void processLCRs() throws Exception
  {
    try
    {
      while(true) 
      {
        /* receive an LCR from outbound server */
        LCR alcr = webDBInfo.getXout().receiveLCR(
                                              XStreamOut.DEFAULT_MODE);
        if (webDBInfo.getXout().getBatchStatus() == XStreamOut.EXECUTING) 
        /* batch is active */
        {
          if (alcr == null)
            continue;

          /* Update the transaction id & init position object */
          if (transactionId == null) 
          {
            transactionId = alcr.getTransactionId();
          }
                    
          if (DEBUG)
          {        
            System.out.println("---- RECEIVED LCR FROM XOUT --");
            System.out.println(alcr.toString());
          }
                    
          /* get the customer id from insert to the order table 
           * Also, pass it on to the XIN for consolidation
           */
          if (alcr.getCommandType().equals("INSERT") &&
              alcr.getObjectName().equals("ORDERS") &&
              alcr.getObjectOwner().equalsIgnoreCase(username))
          {
            processOrdersInsert(alcr);
          }

          /* aggregate the bill amount from the orderline inserts 
           * Also, pass it on to the XIN, for consolidation
           */
          else if(alcr.getCommandType().equals("INSERT") &&
                  alcr.getObjectName().equals("ORDER_LINE") &&
                  alcr.getObjectOwner().equalsIgnoreCase(username))
          {
            processOrderLineInsert(alcr);
          }
          /*
           * On a commit, update the proper customer xin with the
           * changed balance; Also, update the inventory at the 
           * proper item xin.
           */
          else if(alcr.getCommandType().equals("COMMIT"))
          {
            /* construct a position object with the commit lcr's
             * position as the base position
             */
            position = new Position(alcr.getPosition());
            processCommit(alcr);
          }
        }
        else
        {
          assert alcr == null;
          flushData();
        }
      }
    }
    catch(Exception e)
    {
      System.out.println("exception when processing LCRs");
      System.out.println(e.getMessage());
      e.printStackTrace();
      return;
    }
  }

  public static void main(String args[]) throws Exception
  {
    if (args.length < 2)
    {
      System.out.println("Usage:java WPClient <config-file-path> <xstream_admin_passwd>");
      System.exit(0);
    }


    WPClient client = new WPClient(args[0], args[1]);
    client.initConnections();
    client.processLCRs();
    client.closeConnections();
  }
}

